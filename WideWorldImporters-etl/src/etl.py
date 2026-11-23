import os
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window

SRC_HOST = os.getenv("SRC_SQLSERVER_HOST", "wide-world-importers-db")
SRC_PORT = os.getenv("SRC_SQLSERVER_PORT", "1433")
SRC_DB = os.getenv("SRC_SQLSERVER_DB", "WideWorldImporters")
SRC_USER = os.getenv("SRC_SQLSERVER_USER", "sa")
SRC_PASS = os.getenv("SRC_SQLSERVER_PASSWORD", "Dev4oddJob")

DW_HOST = os.getenv("DW_SQLSERVER_HOST", "data-warehouse")
DW_PORT = os.getenv("DW_SQLSERVER_PORT", "1433")
DW_DB = os.getenv("DW_SQLSERVER_DB", "WideWorldImportersDW")
DW_USER = os.getenv("DW_SQLSERVER_USER", "sa")
DW_PASS = os.getenv("DW_SQLSERVER_PASSWORD", "Dev4oddJob")


def build_spark() -> SparkSession:
    return (
        SparkSession.builder.appName("WWI_Inventory_Warehouse_Mart_ETL")
        .config("spark.sql.session.timeZone", "UTC")
        .getOrCreate()
    )


def get_jdbc_url(host: str, port: str, db: str) -> str:
    return (
        f"jdbc:sqlserver://{host}:{port};databaseName={db};"
        "encrypt=true;trustServerCertificate=true;"
    )


def read_sqlserver(spark: SparkSession, host: str, port: str, db: str, user: str, password: str, query: str):
    jdbc_url = get_jdbc_url(host, port, db)
    clean_query = query.strip().rstrip(";")
    return (
        spark.read.format("jdbc")
        .option("url", jdbc_url)
        .option("query", clean_query)
        .option("user", user)
        .option("password", password)
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
        .load()
    )


def clear_dw_tables(spark: SparkSession, host: str, port: str, db: str, user: str, password: str, tables: list[str]):
    """Deletes rows in dependency order (fact first, then dimensions) using Spark's classloader."""
    jdbc_url = get_jdbc_url(host, port, db)
    jvm = spark.sparkContext._jvm
    ctx_loader = jvm.java.lang.Thread.currentThread().getContextClassLoader()
    jvm.java.lang.Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver", True, ctx_loader)

    props = jvm.java.util.Properties()
    props.setProperty("user", user)
    props.setProperty("password", password)

    driver = jvm.java.sql.DriverManager.getDriver(jdbc_url)
    conn = driver.connect(jdbc_url, props)
    try:
        stmt = conn.createStatement()
        try:
            for table in tables:
                stmt.executeUpdate(f"DELETE FROM {table}")
        finally:
            stmt.close()
    finally:
        conn.close()


def write_sqlserver(df, host: str, port: str, db: str, user: str, password: str, table: str, mode: str = "append"):
    jdbc_url = get_jdbc_url(host, port, db)
    (
        df.write.format("jdbc")
        .option("url", jdbc_url)
        .option("dbtable", table)
        .option("user", user)
        .option("password", password)
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
        .option("batchsize", "10000")
        .option("tableLock", "true")
        .mode(mode)
        .save()
    )


def build_dim_date(spark: SparkSession, start_date: str = "2013-01-01", end_date: str = "2027-12-31"):
    dates_df = spark.sql(
        f"SELECT explode(sequence(to_date('{start_date}'), to_date('{end_date}'), interval 1 day)) AS FullDate"
    )
    return dates_df.select(
        F.date_format("FullDate", "yyyyMMdd").cast("int").alias("DateKey"),
        F.col("FullDate"),
        F.dayofmonth("FullDate").cast("tinyint").alias("DayOfMonth"),
        F.date_format("FullDate", "EEEE").alias("DayName"),
        F.dayofweek("FullDate").cast("tinyint").alias("DayOfWeek"),
        F.weekofyear("FullDate").cast("tinyint").alias("WeekOfYear"),
        F.month("FullDate").cast("tinyint").alias("MonthNumber"),
        F.date_format("FullDate", "MMMM").alias("MonthName"),
        F.quarter("FullDate").cast("tinyint").alias("QuarterNumber"),
        F.concat(F.lit("Q"), F.quarter("FullDate").cast("string")).alias("QuarterName"),
        F.year("FullDate").cast("smallint").alias("CalendarYear"),
        F.when(F.dayofweek("FullDate").isin(1, 7), F.lit(True)).otherwise(F.lit(False)).alias("IsWeekend"),
    )


def main():
    spark = build_spark()

    # 1. Extract source tables from WideWorldImporters
    stock_items = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        """
        SELECT StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
               Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode,
               TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit
        FROM Warehouse.StockItems
        """,
    )
    colors = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT ColorID, ColorName FROM Warehouse.Colors",
    )
    package_types = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT PackageTypeID, PackageTypeName FROM Warehouse.PackageTypes",
    )
    stock_groups = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT StockGroupID, StockGroupName FROM Warehouse.StockGroups",
    )
    item_stock_groups = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT StockItemID, StockGroupID FROM Warehouse.StockItemStockGroups",
    )
    suppliers = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        """
        SELECT SupplierID, SupplierName, SupplierCategoryID, DeliveryMethodID,
               DeliveryCityID, PostalCityID, PaymentDays, WebsiteURL
        FROM Purchasing.Suppliers
        """,
    )
    supplier_categories = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT SupplierCategoryID, SupplierCategoryName FROM Purchasing.SupplierCategories",
    )
    delivery_methods = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT DeliveryMethodID, DeliveryMethodName FROM Application.DeliveryMethods",
    )
    cities = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT CityID, CityName FROM Application.Cities",
    )
    transaction_types = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        "SELECT TransactionTypeID, TransactionTypeName FROM Application.TransactionTypes",
    )
    holdings = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        """
        SELECT StockItemID, QuantityOnHand, BinLocation, LastCostPrice,
               ReorderLevel, TargetStockLevel
        FROM Warehouse.StockItemHoldings
        """,
    )
    transactions = read_sqlserver(
        spark, SRC_HOST, SRC_PORT, SRC_DB, SRC_USER, SRC_PASS,
        """
        SELECT StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID,
               InvoiceID, SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity
        FROM Warehouse.StockItemTransactions
        """,
    )

    # 2. Build Denormalized Dimensions
    dim_date = build_dim_date(spark).cache()

    stock_group_agg = (
        item_stock_groups.join(stock_groups, "StockGroupID", "inner")
        .groupBy("StockItemID")
        .agg(F.array_sort(F.collect_set("StockGroupName")).alias("Groups"))
        .withColumn("StockGroupNames", F.concat_ws(", ", "Groups"))
        .select("StockItemID", "StockGroupNames")
    )

    unit_pkg = package_types.select(
        F.col("PackageTypeID").alias("UnitPkgID"),
        F.col("PackageTypeName").alias("UnitPackageName"),
    )
    outer_pkg = package_types.select(
        F.col("PackageTypeID").alias("OuterPkgID"),
        F.col("PackageTypeName").alias("OuterPackageName"),
    )

    dim_stock_item = (
        stock_items.join(colors, "ColorID", "left")
        .join(unit_pkg, stock_items["UnitPackageID"] == unit_pkg["UnitPkgID"], "left")
        .join(outer_pkg, stock_items["OuterPackageID"] == outer_pkg["OuterPkgID"], "left")
        .join(stock_group_agg, "StockItemID", "left")
        .withColumn("StockItemKey", F.row_number().over(Window.orderBy("StockItemID")).cast("int"))
        .select(
            "StockItemKey",
            "StockItemID",
            "StockItemName",
            "Brand",
            "Size",
            "ColorName",
            "UnitPackageName",
            "OuterPackageName",
            F.coalesce("StockGroupNames", F.lit("Unassigned")).alias("StockGroupNames"),
            F.col("IsChillerStock").cast("boolean").alias("IsChillerStock"),
            F.col("LeadTimeDays").cast("int").alias("LeadTimeDays"),
            F.col("QuantityPerOuter").cast("int").alias("QuantityPerOuter"),
            F.col("TaxRate").cast("decimal(18,3)").alias("TaxRate"),
            F.col("UnitPrice").cast("decimal(18,2)").alias("UnitPrice"),
            F.col("RecommendedRetailPrice").cast("decimal(18,2)").alias("RecommendedRetailPrice"),
            F.col("TypicalWeightPerUnit").cast("decimal(18,3)").alias("TypicalWeightPerUnit"),
            "Barcode",
        )
        .cache()
    )

    deliv_city = cities.select(F.col("CityID").alias("DelivCityID"), F.col("CityName").alias("DeliveryCityName"))
    post_city = cities.select(F.col("CityID").alias("PostCityID"), F.col("CityName").alias("PostalCityName"))

    dim_supplier = (
        suppliers.join(supplier_categories, "SupplierCategoryID", "left")
        .join(delivery_methods, "DeliveryMethodID", "left")
        .join(deliv_city, suppliers["DeliveryCityID"] == deliv_city["DelivCityID"], "left")
        .join(post_city, suppliers["PostalCityID"] == post_city["PostCityID"], "left")
        .withColumn("SupplierKey", F.row_number().over(Window.orderBy("SupplierID")).cast("int"))
        .select(
            "SupplierKey",
            "SupplierID",
            "SupplierName",
            "SupplierCategoryName",
            "DeliveryMethodName",
            F.col("PaymentDays").cast("int").alias("PaymentDays"),
            "DeliveryCityName",
            "PostalCityName",
            "WebsiteURL",
        )
        .cache()
    )

    dim_warehouse_location = (
        holdings.select(
            F.coalesce(F.trim(F.col("BinLocation")), F.lit("UNASSIGNED")).alias("BinLocation"),
            F.col("StockItemID"),
        )
        .join(stock_items.select("StockItemID", "IsChillerStock"), "StockItemID", "left")
        .select("BinLocation", F.coalesce(F.col("IsChillerStock"), F.lit(False)).cast("boolean").alias("IsChillerStock"))
        .dropDuplicates(["BinLocation", "IsChillerStock"])
        .withColumn(
            "WarehouseLocationKey",
            F.row_number().over(Window.orderBy("BinLocation", "IsChillerStock")).cast("int"),
        )
        .select("WarehouseLocationKey", "BinLocation", "IsChillerStock")
        .cache()
    )

    dim_transaction_type = (
        transaction_types.withColumn(
            "TransactionTypeKey", F.row_number().over(Window.orderBy("TransactionTypeID")).cast("int")
        )
        .select("TransactionTypeKey", "TransactionTypeID", "TransactionTypeName")
        .cache()
    )

    # 3. Build Single Fact Table (FactStockItemTransactions)
    tx_enriched = (
        transactions.join(stock_items.select("StockItemID", F.col("SupplierID").alias("DefaultSupplierID")), "StockItemID", "left")
        .withColumn("EffectiveSupplierID", F.coalesce(F.col("SupplierID"), F.col("DefaultSupplierID")))
        .withColumn("TransactionDateKey", F.date_format(F.to_date("TransactionOccurredWhen"), "yyyyMMdd").cast("int"))
        .join(holdings, "StockItemID", "left")
        .withColumn("CleanBinLocation", F.coalesce(F.trim(F.col("BinLocation")), F.lit("UNASSIGNED")))
    )

    fact_df = (
        tx_enriched.join(dim_stock_item.select("StockItemKey", "StockItemID", "IsChillerStock"), "StockItemID", "inner")
        .join(
            dim_supplier.select("SupplierKey", "SupplierID"),
            tx_enriched["EffectiveSupplierID"] == dim_supplier["SupplierID"],
            "left",
        )
        .join(
            dim_warehouse_location,
            (tx_enriched["CleanBinLocation"] == dim_warehouse_location["BinLocation"])
            & (dim_stock_item["IsChillerStock"] == dim_warehouse_location["IsChillerStock"]),
            "left",
        )
        .join(dim_transaction_type.select("TransactionTypeKey", "TransactionTypeID"), "TransactionTypeID", "inner")
        .withColumn("StockItemTransactionKey", F.row_number().over(Window.orderBy("StockItemTransactionID")).cast("bigint"))
        .withColumn("QtyOnHandDec", F.coalesce(F.col("QuantityOnHand").cast("decimal(18,3)"), F.lit(0.0)))
        .withColumn("LastCostDec", F.coalesce(F.col("LastCostPrice").cast("decimal(18,2)"), F.lit(0.0)))
        .withColumn("ReorderLvlDec", F.coalesce(F.col("ReorderLevel").cast("decimal(18,3)"), F.lit(0.0)))
        .withColumn("TargetLvlDec", F.coalesce(F.col("TargetStockLevel").cast("decimal(18,3)"), F.lit(0.0)))
        .select(
            "StockItemTransactionKey",
            F.col("StockItemTransactionID").cast("int").alias("StockItemTransactionID"),
            "TransactionDateKey",
            "StockItemKey",
            F.coalesce(F.col("SupplierKey"), F.lit(-1)).cast("int").alias("SupplierKey"),
            F.coalesce(F.col("WarehouseLocationKey"), F.lit(-1)).cast("int").alias("WarehouseLocationKey"),
            "TransactionTypeKey",
            F.col("CustomerID").cast("int").alias("CustomerID"),
            F.col("InvoiceID").cast("int").alias("InvoiceID"),
            F.col("PurchaseOrderID").cast("int").alias("PurchaseOrderID"),
            F.col("TransactionOccurredWhen").cast("timestamp").alias("TransactionOccurredWhen"),
            F.col("Quantity").cast("decimal(18,3)").alias("TransactionQuantity"),
            F.col("QtyOnHandDec").alias("QuantityOnHand"),
            F.col("LastCostDec").alias("LastCostPrice"),
            F.col("ReorderLvlDec").alias("ReorderLevel"),
            F.col("TargetLvlDec").alias("TargetStockLevel"),
            (F.col("QtyOnHandDec") * F.col("LastCostDec")).cast("decimal(18,2)").alias("StockHoldingValue"),
            F.when(
                F.col("QtyOnHandDec") < F.col("ReorderLvlDec"),
                (F.col("TargetLvlDec") - F.col("QtyOnHandDec")).cast("decimal(18,3)"),
            )
            .otherwise(F.lit(0.0).cast("decimal(18,3)"))
            .alias("ReorderDeficit"),
        )
    )

    # 4. Clear existing rows in FK-safe order, then append (dimensions first)
    clear_dw_tables(
        spark,
        DW_HOST,
        DW_PORT,
        DW_DB,
        DW_USER,
        DW_PASS,
        [
            "dw.FactStockItemTransactions",
            "dw.DimDate",
            "dw.DimStockItem",
            "dw.DimSupplier",
            "dw.DimWarehouseLocation",
            "dw.DimTransactionType",
        ],
    )

    write_sqlserver(dim_date, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.DimDate", mode="append")
    write_sqlserver(dim_stock_item, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.DimStockItem", mode="append")
    write_sqlserver(dim_supplier, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.DimSupplier", mode="append")
    write_sqlserver(dim_warehouse_location, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.DimWarehouseLocation", mode="append")
    write_sqlserver(dim_transaction_type, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.DimTransactionType", mode="append")
    write_sqlserver(fact_df, DW_HOST, DW_PORT, DW_DB, DW_USER, DW_PASS, "dw.FactStockItemTransactions", mode="append")

    spark.stop()


if __name__ == "__main__":
    main()

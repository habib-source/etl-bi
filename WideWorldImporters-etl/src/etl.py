from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, to_date, year, month, dayofmonth, dayofweek

# 1. Initialize Spark Session with SQL Server JDBC Support
spark = SparkSession.builder \
    .appName("WWI_Inventory_Warehouse_Mart_ETL") \
    .config("spark.jars.packages", "com.microsoft.sqlserver:mssql-jdbc:12.2.1.jre8.jar") \
    .getOrCreate()

# Connection Configurations
SOURCE_URL = "jdbc:sqlserver://wide-world-importers-db:1433;database=WideWorldImporters;encrypt=true;trustServerCertificate=false;"
TARGET_URL = "jdbc:sqlserver://data-warehouse:1433;database=WideWorldImportersDW;encrypt=true;trustServerCertificate=false;"

CONNECTION_PROPERTIES = {
    "user": "sa",
    "password": "Dev4oddJob",
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

print("=== STARTING INVENTORY & WAREHOUSE MART ETL ===")

# ==========================================
# 2. EXTRACT LAYER (Read from Source OLTP)
# ==========================================
print("Extracting data from WideWorldImporters source...")

df_stock_items = spark.read.jdbc(SOURCE_URL, "Warehouse.StockItems", properties=CONNECTION_PROPERTIES)
df_stock_holdings = spark.read.jdbc(SOURCE_URL, "Warehouse.StockItemHoldings", properties=CONNECTION_PROPERTIES)
df_stock_transactions = spark.read.jdbc(SOURCE_URL, "Warehouse.StockItemTransactions", properties=CONNECTION_PROPERTIES)
df_suppliers = spark.read.jdbc(SOURCE_URL, "Purchasing.Suppliers", properties=CONNECTION_PROPERTIES)
df_supplier_categories = spark.read.jdbc(SOURCE_URL, "Purchasing.SupplierCategories", properties=CONNECTION_PROPERTIES)

# ==========================================
# 3. TRANSFORM LAYER (Build Dims & Facts)
# ==========================================
print("Transforming dimensions and facts...")

# --- Dimension: Dim_StockItem ---
dim_stock_item = df_stock_items.select(
    col("StockItemID"),
    col("StockItemName"),
    col("Brand"),
    col("Size"),
    col("TypicalWeightPerUnit"),
    col("IsChillerStock"),
    col("LeadTimeDays"),
    col("UnitPrice"),
    col("RecommendedRetailPrice")
).withColumn("ETL_LoadedAt", current_timestamp())

# --- Dimension: Dim_Supplier ---
dim_supplier = df_suppliers.alias("s") \
    .join(df_supplier_categories.alias("sc"), col("s.SupplierCategoryID") == col("sc.SupplierCategoryID"), "left") \
    .select(
        col("s.SupplierID"),
        col("s.SupplierName"),
        col("sc.SupplierCategoryName"),
        col("s.PaymentDays"),
        col("s.WebsiteURL")
    ).withColumn("ETL_LoadedAt", current_timestamp())

# --- Dimension: Dim_Date (Generated from Transaction Dates) ---
dates_df = df_stock_transactions.select(to_date(col("TransactionOccurredWhen")).alias("FullDate")).distinct()
dim_date = dates_df.select(
    col("FullDate"),
    year(col("FullDate")).alias("CalendarYear"),
    month(col("FullDate")).alias("CalendarMonth"),
    dayofmonth(col("FullDate")).alias("DayOfMonth"),
    dayofweek(col("FullDate")).alias("DayOfWeek")
).filter(col("FullDate").isNotNull()).withColumn("ETL_LoadedAt", current_timestamp())

# --- Fact: Fact_InventorySnapshots (Current Holdings & Valuation) ---
fact_inventory_snapshots = df_stock_holdings.alias("h") \
    .join(df_stock_items.alias("i"), col("h.StockItemID") == col("i.StockItemID"), "inner") \
    .select(
        col("h.StockItemID"),
        col("i.SupplierID"),
        col("h.QuantityOnHand"),
        col("h.BinLocation"),
        col("h.LastStocktakeQuantity"),
        col("h.LastCostPrice"),
        col("h.ReorderLevel"),
        col("h.TargetStockLevel"),
        (col("h.QuantityOnHand") * col("h.LastCostPrice")).alias("TotalStockholdingValue"),
        (col("h.TargetStockLevel") - col("h.QuantityOnHand")).alias("ReorderDeficit")
    ).withColumn("SnapshotDate", current_timestamp())

# --- Fact: Fact_StockItemTransactions ---
fact_stock_transactions = df_stock_transactions.select(
    col("StockItemTransactionID"),
    col("StockItemID"),
    col("TransactionTypeID"),
    col("CustomerID"),
    col("InvoiceID"),
    col("SupplierID"),
    col("PurchaseOrderID"),
    col("TransactionOccurredWhen"),
    col("Quantity"),
    col("LastEditedWhen")
).withColumn("ETL_LoadedAt", current_timestamp())

# ==========================================
# 4. LOAD LAYER (Write to Data Warehouse)
# ==========================================
print("Loading transformed data into Target SQL Server Data Warehouse...")

def write_to_dw(df, table_name):
    df.write.jdbc(
        url=TARGET_URL,
        table=table_name,
        mode="overwrite", # Use "append" if implementing incremental micro-batches
        properties=CONNECTION_PROPERTIES
    )
    print(f"Successfully loaded table: {table_name}")

# Write Dimensions first
write_to_dw(dim_stock_item, "Dim.StockItem")
write_to_dw(dim_supplier, "Dim.Supplier")
write_to_dw(dim_date, "Dim.Date")

# Write Facts
write_to_dw(fact_inventory_snapshots, "Fact.InventorySnapshots")
write_to_dw(fact_stock_transactions, "Fact.StockItemTransactions")

print("=== INVENTORY ETL PIPELINE COMPLETED SUCCESSFULLY ===")
spark.stop()

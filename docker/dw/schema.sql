CREATE SCHEMA dw;

CREATE TABLE dw.DimDate (
    DateKey INT NOT NULL PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayOfMonth TINYINT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    DayOfWeek TINYINT NOT NULL,
    WeekOfYear TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    QuarterNumber TINYINT NOT NULL,
    QuarterName VARCHAR(6) NOT NULL,
    CalendarYear SMALLINT NOT NULL,
    IsWeekend BIT NOT NULL
);

CREATE TABLE dw.DimStockItem (
    StockItemKey INT NOT NULL PRIMARY KEY,
    StockItemID INT NOT NULL,
    StockItemName NVARCHAR(100) NOT NULL,
    Brand NVARCHAR(50),
    Size NVARCHAR(20),
    ColorName NVARCHAR(50),
    UnitPackageName NVARCHAR(50),
    OuterPackageName NVARCHAR(50),
    StockGroupNames NVARCHAR(400),
    IsChillerStock BIT NOT NULL,
    LeadTimeDays INT NOT NULL,
    QuantityPerOuter INT NOT NULL,
    TaxRate DECIMAL(18, 3) NOT NULL,
    UnitPrice DECIMAL(18, 2) NOT NULL,
    RecommendedRetailPrice DECIMAL(18, 2),
    TypicalWeightPerUnit DECIMAL(18, 3) NOT NULL,
    Barcode NVARCHAR(50)
);

CREATE TABLE dw.DimSupplier (
    SupplierKey INT NOT NULL PRIMARY KEY,
    SupplierID INT NOT NULL,
    SupplierName NVARCHAR(100) NOT NULL,
    SupplierCategoryName NVARCHAR(50),
    DeliveryMethodName NVARCHAR(50),
    PaymentDays INT NOT NULL,
    DeliveryCityName NVARCHAR(50),
    PostalCityName NVARCHAR(50),
    WebsiteURL NVARCHAR(256)
);

CREATE TABLE dw.DimWarehouseLocation (
    WarehouseLocationKey INT NOT NULL PRIMARY KEY,
    BinLocation NVARCHAR(20) NOT NULL,
    IsChillerStock BIT NOT NULL
);

CREATE TABLE dw.DimTransactionType (
    TransactionTypeKey INT NOT NULL PRIMARY KEY,
    TransactionTypeID INT NOT NULL,
    TransactionTypeName NVARCHAR(50) NOT NULL
);

CREATE TABLE dw.FactStockItemTransactions (
    StockItemTransactionKey BIGINT NOT NULL PRIMARY KEY,
    StockItemTransactionID INT NOT NULL,
    TransactionDateKey INT NOT NULL,
    StockItemKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    WarehouseLocationKey INT NOT NULL,
    TransactionTypeKey INT NOT NULL,
    CustomerID INT,
    InvoiceID INT,
    PurchaseOrderID INT,
    TransactionOccurredWhen DATETIME2(7) NOT NULL,
    TransactionQuantity DECIMAL(18, 3) NOT NULL,
    QuantityOnHand DECIMAL(18, 3) NOT NULL,
    LastCostPrice DECIMAL(18, 2) NOT NULL,
    ReorderLevel DECIMAL(18, 3) NOT NULL,
    TargetStockLevel DECIMAL(18, 3) NOT NULL,
    StockHoldingValue DECIMAL(18, 2) NOT NULL,
    ReorderDeficit DECIMAL(18, 3) NOT NULL,
    CONSTRAINT FK_FactStockItemTransactions_DimDate
        FOREIGN KEY (TransactionDateKey) REFERENCES dw.DimDate (DateKey),
    CONSTRAINT FK_FactStockItemTransactions_DimStockItem
        FOREIGN KEY (StockItemKey) REFERENCES dw.DimStockItem (StockItemKey),
    CONSTRAINT FK_FactStockItemTransactions_DimSupplier
        FOREIGN KEY (SupplierKey) REFERENCES dw.DimSupplier (SupplierKey),
    CONSTRAINT FK_FactStockItemTransactions_DimWarehouseLocation
        FOREIGN KEY (WarehouseLocationKey) REFERENCES dw.DimWarehouseLocation (WarehouseLocationKey),
    CONSTRAINT FK_FactStockItemTransactions_DimTransactionType
        FOREIGN KEY (TransactionTypeKey) REFERENCES dw.DimTransactionType (TransactionTypeKey)
);

CREATE INDEX IX_FactStockItemTransactions_TransactionDateKey
    ON dw.FactStockItemTransactions (TransactionDateKey);

CREATE INDEX IX_FactStockItemTransactions_StockItemKey
    ON dw.FactStockItemTransactions (StockItemKey);

CREATE INDEX IX_FactStockItemTransactions_SupplierKey
    ON dw.FactStockItemTransactions (SupplierKey);

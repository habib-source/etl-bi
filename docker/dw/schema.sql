CREATE SCHEMA [Dim];
CREATE SCHEMA [Fact];

CREATE TABLE [Dim].[StockItem] (
    [StockItemID] INT NOT NULL,
    [StockItemName] NVARCHAR(100) NOT NULL,
    [Brand] NVARCHAR(50),
    [Size] NVARCHAR(20),
    [TypicalWeightPerUnit] DECIMAL(18, 3) NOT NULL,
    [IsChillerStock] BIT NOT NULL,
    [LeadTimeDays] INT NOT NULL,
    [UnitPrice] DECIMAL(18, 2) NOT NULL,
    [RecommendedRetailPrice] DECIMAL(18, 2),
    [ETL_LoadedAt] DATETIME2(6) NOT NULL,
    CONSTRAINT [PK_Dim_StockItem] PRIMARY KEY CLUSTERED ([StockItemID] ASC)
);

CREATE TABLE [Dim].[Supplier] (
    [SupplierID] INT NOT NULL,
    [SupplierName] NVARCHAR(100) NOT NULL,
    [SupplierCategoryName] NVARCHAR(50),
    [PaymentDays] INT NOT NULL,
    [WebsiteURL] NVARCHAR(256) NOT NULL,
    [ETL_LoadedAt] DATETIME2(6) NOT NULL,
    CONSTRAINT [PK_Dim_Supplier] PRIMARY KEY CLUSTERED ([SupplierID] ASC)
);

CREATE TABLE [Dim].[Date] (
    [FullDate] DATE NOT NULL,
    [CalendarYear] INT NOT NULL,
    [CalendarMonth] INT NOT NULL,
    [DayOfMonth] INT NOT NULL,
    [DayOfWeek] INT NOT NULL,
    [ETL_LoadedAt] DATETIME2(6) NOT NULL,
    CONSTRAINT [PK_Dim_Date] PRIMARY KEY CLUSTERED ([FullDate] ASC)
);

CREATE TABLE [Fact].[InventorySnapshots] (
    [StockItemID] INT NOT NULL,
    [SupplierID] INT NOT NULL,
    [QuantityOnHand] INT NOT NULL,
    [BinLocation] NVARCHAR(20) NOT NULL,
    [LastStocktakeQuantity] INT NOT NULL,
    [LastCostPrice] DECIMAL(18, 2) NOT NULL,
    [ReorderLevel] INT,
    [TargetStockLevel] INT,
    [TotalStockholdingValue] DECIMAL(38, 4),
    [ReorderDeficit] BIGINT,
    [SnapshotDate] DATETIME2(6) NOT NULL,
    CONSTRAINT [FK_Fact_InventorySnapshots_StockItem]
        FOREIGN KEY ([StockItemID]) REFERENCES [Dim].[StockItem] ([StockItemID]),
    CONSTRAINT [FK_Fact_InventorySnapshots_Supplier]
        FOREIGN KEY ([SupplierID]) REFERENCES [Dim].[Supplier] ([SupplierID])
);

CREATE CLUSTERED INDEX [IX_Fact_InventorySnapshots_StockItem]
    ON [Fact].[InventorySnapshots] ([StockItemID] ASC, [SnapshotDate] DESC);

CREATE TABLE [Fact].[StockItemTransactions] (
    [StockItemTransactionID] INT NOT NULL,
    [StockItemID] INT NOT NULL,
    [TransactionTypeID] INT NOT NULL,
    [CustomerID] INT,
    [InvoiceID] INT,
    [SupplierID] INT,
    [PurchaseOrderID] INT,
    [TransactionOccurredWhen] DATETIME2(7) NOT NULL,
    [Quantity] DECIMAL(18, 3) NOT NULL,
    [LastEditedWhen] DATETIME2(7) NOT NULL,
    [ETL_LoadedAt] DATETIME2(6) NOT NULL,
    CONSTRAINT [PK_Fact_StockItemTransactions]
        PRIMARY KEY CLUSTERED ([StockItemTransactionID] ASC),
    CONSTRAINT [FK_Fact_StockItemTransactions_StockItem]
        FOREIGN KEY ([StockItemID]) REFERENCES [Dim].[StockItem] ([StockItemID]),
    CONSTRAINT [FK_Fact_StockItemTransactions_Supplier]
        FOREIGN KEY ([SupplierID]) REFERENCES [Dim].[Supplier] ([SupplierID])
);

CREATE NONCLUSTERED INDEX [IX_Fact_StockItemTransactions_OccurredWhen]
    ON [Fact].[StockItemTransactions] ([TransactionOccurredWhen] ASC)
    INCLUDE ([StockItemID], [Quantity]);

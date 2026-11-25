USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* -------------------------------------------------------------------------
       0. Ensure minimal reference rows exist (safe if already populated)
       ------------------------------------------------------------------------- */
    DECLARE @ActorPersonID INT = (SELECT TOP 1 PersonID FROM Application.People ORDER BY PersonID);
    IF @ActorPersonID IS NULL
    BEGIN
        SET IDENTITY_INSERT Application.People ON;
        INSERT INTO Application.People (
            PersonID, FullName, PreferredName, SearchName,
            IsPermittedToLogon, IsExternalLogonProvider, IsSystemUser, IsEmployee, IsSalesperson,
            LastEditedBy
        )
        VALUES (
            1, N'ETL Test Admin', N'Admin', N'Admin ETL Test Admin',
            0, 0, 1, 1, 0, 1
        );
        SET IDENTITY_INSERT Application.People OFF;
        SET @ActorPersonID = 1;
    END

    -- Country & StateProvince for Cities
    DECLARE @CountryID INT = (SELECT TOP 1 CountryID FROM Application.Countries ORDER BY CountryID);
    IF @CountryID IS NULL
    BEGIN
        SET IDENTITY_INSERT Application.Countries ON;
        INSERT INTO Application.Countries (
            CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode,
            CountryType, LatestRecordedPopulation, Continent, Region, Subregion, LastEditedBy
        )
        VALUES (
            1, N'United States', N'United States of America', N'USA', 840,
            N'Nation', 335000000, N'Americas', N'Americas', N'Northern America', @ActorPersonID
        );
        SET IDENTITY_INSERT Application.Countries OFF;
        SET @CountryID = 1;
    END

    DECLARE @StateProvinceID INT = (SELECT TOP 1 StateProvinceID FROM Application.StateProvinces ORDER BY StateProvinceID);
    IF @StateProvinceID IS NULL
    BEGIN
        SET IDENTITY_INSERT Application.StateProvinces ON;
        INSERT INTO Application.StateProvinces (
            StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
            SalesTerritory, LatestRecordedPopulation, LastEditedBy
        )
        VALUES (
            1, N'WA', N'Washington', @CountryID,
            N'Far West', 7800000, @ActorPersonID
        );
        SET IDENTITY_INSERT Application.StateProvinces OFF;
        SET @StateProvinceID = 1;
    END

    -- Cities (IDs 9001, 9002)
    SET IDENTITY_INSERT Application.Cities ON;
    IF NOT EXISTS (SELECT 1 FROM Application.Cities WHERE CityID = 9001)
        INSERT INTO Application.Cities (CityID, CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
        VALUES (9001, N'Seattle Test', @StateProvinceID, 750000, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Application.Cities WHERE CityID = 9002)
        INSERT INTO Application.Cities (CityID, CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
        VALUES (9002, N'Portland Test', @StateProvinceID, 640000, @ActorPersonID);
    SET IDENTITY_INSERT Application.Cities OFF;

    -- DeliveryMethods (IDs 901, 902)
    SET IDENTITY_INSERT Application.DeliveryMethods ON;
    IF NOT EXISTS (SELECT 1 FROM Application.DeliveryMethods WHERE DeliveryMethodID = 901)
        INSERT INTO Application.DeliveryMethods (DeliveryMethodID, DeliveryMethodName, LastEditedBy)
        VALUES (901, N'Refrigerated Truck', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Application.DeliveryMethods WHERE DeliveryMethodID = 902)
        INSERT INTO Application.DeliveryMethods (DeliveryMethodID, DeliveryMethodName, LastEditedBy)
        VALUES (902, N'Courier Express', @ActorPersonID);
    SET IDENTITY_INSERT Application.DeliveryMethods OFF;

    -- TransactionTypes (IDs 91, 92)
    SET IDENTITY_INSERT Application.TransactionTypes ON;
    IF NOT EXISTS (SELECT 1 FROM Application.TransactionTypes WHERE TransactionTypeID = 91)
        INSERT INTO Application.TransactionTypes (TransactionTypeID, TransactionTypeName, LastEditedBy)
        VALUES (91, N'Stock Receipt (Test)', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Application.TransactionTypes WHERE TransactionTypeID = 92)
        INSERT INTO Application.TransactionTypes (TransactionTypeID, TransactionTypeName, LastEditedBy)
        VALUES (92, N'Stock Issue (Test)', @ActorPersonID);
    SET IDENTITY_INSERT Application.TransactionTypes OFF;

    -- SupplierCategories (IDs 91, 92)
    SET IDENTITY_INSERT Purchasing.SupplierCategories ON;
    IF NOT EXISTS (SELECT 1 FROM Purchasing.SupplierCategories WHERE SupplierCategoryID = 91)
        INSERT INTO Purchasing.SupplierCategories (SupplierCategoryID, SupplierCategoryName, LastEditedBy)
        VALUES (91, N'Novelty & Merch', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Purchasing.SupplierCategories WHERE SupplierCategoryID = 92)
        INSERT INTO Purchasing.SupplierCategories (SupplierCategoryID, SupplierCategoryName, LastEditedBy)
        VALUES (92, N'Chilled Goods', @ActorPersonID);
    SET IDENTITY_INSERT Purchasing.SupplierCategories OFF;

    -- Warehouse Colors (IDs 91, 92)
    SET IDENTITY_INSERT Warehouse.Colors ON;
    IF NOT EXISTS (SELECT 1 FROM Warehouse.Colors WHERE ColorID = 91)
        INSERT INTO Warehouse.Colors (ColorID, ColorName, LastEditedBy)
        VALUES (91, N'Cobalt Blue', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.Colors WHERE ColorID = 92)
        INSERT INTO Warehouse.Colors (ColorID, ColorName, LastEditedBy)
        VALUES (92, N'Crimson Red', @ActorPersonID);
    SET IDENTITY_INSERT Warehouse.Colors OFF;

    -- Warehouse PackageTypes (IDs 91, 92)
    SET IDENTITY_INSERT Warehouse.PackageTypes ON;
    IF NOT EXISTS (SELECT 1 FROM Warehouse.PackageTypes WHERE PackageTypeID = 91)
        INSERT INTO Warehouse.PackageTypes (PackageTypeID, PackageTypeName, LastEditedBy)
        VALUES (91, N'Each', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.PackageTypes WHERE PackageTypeID = 92)
        INSERT INTO Warehouse.PackageTypes (PackageTypeID, PackageTypeName, LastEditedBy)
        VALUES (92, N'Carton', @ActorPersonID);
    SET IDENTITY_INSERT Warehouse.PackageTypes OFF;

    -- Warehouse StockGroups (IDs 91, 92, 93)
    SET IDENTITY_INSERT Warehouse.StockGroups ON;
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockGroups WHERE StockGroupID = 91)
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (91, N'T-Shirts', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockGroups WHERE StockGroupID = 92)
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (92, N'Limited Edition', @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockGroups WHERE StockGroupID = 93)
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (93, N'Cold Chain', @ActorPersonID);
    SET IDENTITY_INSERT Warehouse.StockGroups OFF;

    /* -------------------------------------------------------------------------
       1. Suppliers (IDs 901, 902)
       ------------------------------------------------------------------------- */
    SET IDENTITY_INSERT Purchasing.Suppliers ON;
    IF NOT EXISTS (SELECT 1 FROM Purchasing.Suppliers WHERE SupplierID = 901)
        INSERT INTO Purchasing.Suppliers (
            SupplierID, SupplierName, SupplierCategoryID,
            PrimaryContactPersonID, AlternateContactPersonID,
            DeliveryMethodID, DeliveryCityID, PostalCityID,
            SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode,
            BankAccountNumber, BankInternationalCode, PaymentDays,
            PhoneNumber, FaxNumber, WebsiteURL,
            DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode,
            LastEditedBy
        )
        VALUES (
            901, N'Northwind Merch Supply', 91,
            @ActorPersonID, @ActorPersonID,
            902, 9001, 9001,
            N'REF-NWM-901', N'Northwind Acct', N'Main Branch', N'021000021',
            N'100901001', N'NWUS33', 30,
            N'(206) 555-0191', N'(206) 555-0192', N'https://northwind-merch.example.com',
            N'100 Pike St', N'98101', N'PO Box 901', N'98101',
            @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Purchasing.Suppliers WHERE SupplierID = 902)
        INSERT INTO Purchasing.Suppliers (
            SupplierID, SupplierName, SupplierCategoryID,
            PrimaryContactPersonID, AlternateContactPersonID,
            DeliveryMethodID, DeliveryCityID, PostalCityID,
            SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode,
            BankAccountNumber, BankInternationalCode, PaymentDays,
            PhoneNumber, FaxNumber, WebsiteURL,
            DeliveryAddressLine1, DeliveryPostalCode, PostalAddressLine1, PostalPostalCode,
            LastEditedBy
        )
        VALUES (
            902, N'Cascade Frost Logistics', 92,
            @ActorPersonID, @ActorPersonID,
            901, 9002, 9002,
            N'REF-CFL-902', N'Cascade Acct', N'West Branch', N'021000089',
            N'200902002', N'CFUS44', 14,
            N'(503) 555-0144', N'(503) 555-0145', N'https://cascade-frost.example.com',
            N'200 Burnside St', N'97209', N'PO Box 902', N'97209',
            @ActorPersonID
        );
    SET IDENTITY_INSERT Purchasing.Suppliers OFF;

    /* -------------------------------------------------------------------------
       2. StockItems (IDs 9001, 9002, 9003)
          - 9001: Multi-group (T-Shirts, Limited Edition), non-chiller, Supplier 901
          - 9002: Single-group (Cold Chain), chiller, Supplier 902
          - 9003: Unassigned stock group (no StockItemStockGroups row), non-chiller
       ------------------------------------------------------------------------- */
    SET IDENTITY_INSERT Warehouse.StockItems ON;
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItems WHERE StockItemID = 9001)
        INSERT INTO Warehouse.StockItems (
            StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
            Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode,
            TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, LastEditedBy
        )
        VALUES (
            9001, N'WWI Developer Tee (Cobalt)', 901, 91, 91, 92,
            N'WWI', N'L', 7, 24, 0, N'00900100000001',
            15.000, 19.99, 29.99, 0.250, @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItems WHERE StockItemID = 9002)
        INSERT INTO Warehouse.StockItems (
            StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
            Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode,
            TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, LastEditedBy
        )
        VALUES (
            9002, N'Artisan Chilled Gel Pack', 902, 92, 91, 92,
            N'Cascade', N'500g', 3, 12, 1, N'00900200000002',
            8.500, 6.50, 9.99, 0.520, @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItems WHERE StockItemID = 9003)
        INSERT INTO Warehouse.StockItems (
            StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
            Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode,
            TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, LastEditedBy
        )
        VALUES (
            9003, N'Unclassified Test Widget', 901, NULL, 91, 91,
            NULL, N'Standard', 14, 1, 0, NULL,
            15.000, 12.00, 18.00, 0.100, @ActorPersonID
        );
    SET IDENTITY_INSERT Warehouse.StockItems OFF;

    /* -------------------------------------------------------------------------
       3. StockItemStockGroups (9001 has 2 groups; 9002 has 1; 9003 has 0)
       ------------------------------------------------------------------------- */
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9001 AND StockGroupID = 91)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9001, 91, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9001 AND StockGroupID = 92)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9001, 92, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9002 AND StockGroupID = 93)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9002, 93, @ActorPersonID);

    /* -------------------------------------------------------------------------
       4. StockItemHoldings (PK = StockItemID)
          - 9001: QuantityOnHand (120) >= ReorderLevel (50) -> ReorderDeficit = 0
          - 9002: QuantityOnHand (15) < ReorderLevel (40), Target = 100 -> ReorderDeficit = 85
          - 9003: Whitespace BinLocation ('   ') -> normalizes to 'UNASSIGNED'
       ------------------------------------------------------------------------- */
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemHoldings WHERE StockItemID = 9001)
        INSERT INTO Warehouse.StockItemHoldings (
            StockItemID, QuantityOnHand, BinLocation, LastStocktakeQuantity,
            LastCostPrice, ReorderLevel, TargetStockLevel, LastEditedBy
        )
        VALUES (9001, 120, N'A-01-01', 120, 11.25, 50, 150, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemHoldings WHERE StockItemID = 9002)
        INSERT INTO Warehouse.StockItemHoldings (
            StockItemID, QuantityOnHand, BinLocation, LastStocktakeQuantity,
            LastCostPrice, ReorderLevel, TargetStockLevel, LastEditedBy
        )
        VALUES (9002, 15, N'C-04-02', 20, 4.10, 40, 100, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemHoldings WHERE StockItemID = 9003)
        INSERT INTO Warehouse.StockItemHoldings (
            StockItemID, QuantityOnHand, BinLocation, LastStocktakeQuantity,
            LastCostPrice, ReorderLevel, TargetStockLevel, LastEditedBy
        )
        VALUES (9003, 30, N'   ', 30, 7.00, 10, 50, @ActorPersonID);

    /* -------------------------------------------------------------------------
       5. StockItemTransactions (IDs 90001..90004)
          - 90001: Receipt for 9001 with explicit SupplierID = 901
          - 90002: Issue for 9001 with SupplierID = NULL (tests fallback to 901)
          - 90003: Receipt for 9002 (chiller) with SupplierID = 902
          - 90004: Receipt for 9003 (UNASSIGNED bin) with SupplierID = NULL
       ------------------------------------------------------------------------- */
    SET IDENTITY_INSERT Warehouse.StockItemTransactions ON;
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID = 90001)
        INSERT INTO Warehouse.StockItemTransactions (
            StockItemTransactionID, StockItemID, TransactionTypeID,
            CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
            TransactionOccurredWhen, Quantity, LastEditedBy
        )
        VALUES (
            90001, 9001, 91,
            NULL, NULL, 901, NULL,
            '2026-11-10T09:30:00', 100.000, @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID = 90002)
        INSERT INTO Warehouse.StockItemTransactions (
            StockItemTransactionID, StockItemID, TransactionTypeID,
            CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
            TransactionOccurredWhen, Quantity, LastEditedBy
        )
        VALUES (
            90002, 9001, 92,
            NULL, NULL, NULL, NULL,
            '2026-11-12T14:15:00', -25.000, @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID = 90003)
        INSERT INTO Warehouse.StockItemTransactions (
            StockItemTransactionID, StockItemID, TransactionTypeID,
            CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
            TransactionOccurredWhen, Quantity, LastEditedBy
        )
        VALUES (
            90003, 9002, 91,
            NULL, NULL, 902, NULL,
            '2026-11-15T08:00:00', 50.000, @ActorPersonID
        );

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID = 90004)
        INSERT INTO Warehouse.StockItemTransactions (
            StockItemTransactionID, StockItemID, TransactionTypeID,
            CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
            TransactionOccurredWhen, Quantity, LastEditedBy
        )
        VALUES (
            90004, 9003, 91,
            NULL, NULL, NULL, NULL,
            '2026-11-20T16:45:00', 30.000, @ActorPersonID
        );
    SET IDENTITY_INSERT Warehouse.StockItemTransactions OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

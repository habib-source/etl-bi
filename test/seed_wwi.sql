USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* -------------------------------------------------------------------------
       0. Ensure minimal reference rows exist (safe if already populated)
       ------------------------------------------------------------------------- */
    DECLARE @ActorPersonID INT = (SELECT TOP 1 PersonID FROM Application.People ORDER BY PersonID);
    IF @ActorPersonID IS NULL
    BEGIN
        IF OBJECTPROPERTY(OBJECT_ID(N'Application.People'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.People ON;

        INSERT INTO Application.People (
            PersonID, FullName, PreferredName,
            IsPermittedToLogon, IsExternalLogonProvider, IsSystemUser, IsEmployee, IsSalesperson,
            LastEditedBy
        )
        VALUES (
            1, N'ETL Test Admin', N'Admin',
            0, 0, 1, 1, 0, 1
        );

        IF OBJECTPROPERTY(OBJECT_ID(N'Application.People'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.People OFF;

        SET @ActorPersonID = 1;
    END;

    DECLARE @CountryID INT = (SELECT TOP 1 CountryID FROM Application.Countries ORDER BY CountryID);
    IF @CountryID IS NULL
    BEGIN
        IF OBJECTPROPERTY(OBJECT_ID(N'Application.Countries'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.Countries ON;

        INSERT INTO Application.Countries (
            CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode,
            CountryType, LatestRecordedPopulation, Continent, Region, Subregion, LastEditedBy
        )
        VALUES (
            1, N'United States', N'United States of America', N'USA', 840,
            N'Nation', 335000000, N'Americas', N'Americas', N'Northern America', @ActorPersonID
        );

        IF OBJECTPROPERTY(OBJECT_ID(N'Application.Countries'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.Countries OFF;

        SET @CountryID = 1;
    END;

    DECLARE @StateProvinceID INT = (SELECT TOP 1 StateProvinceID FROM Application.StateProvinces ORDER BY StateProvinceID);
    IF @StateProvinceID IS NULL
    BEGIN
        IF OBJECTPROPERTY(OBJECT_ID(N'Application.StateProvinces'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.StateProvinces ON;

        INSERT INTO Application.StateProvinces (
            StateProvinceID, StateProvinceCode, StateProvinceName, CountryID,
            SalesTerritory, LatestRecordedPopulation, LastEditedBy
        )
        VALUES (
            1, N'WA', N'Washington', @CountryID,
            N'Far West', 7800000, @ActorPersonID
        );

        IF OBJECTPROPERTY(OBJECT_ID(N'Application.StateProvinces'), 'TableHasIdentity') = 1
            SET IDENTITY_INSERT Application.StateProvinces OFF;

        SET @StateProvinceID = 1;
    END;

    -- Cities (lookup by CityName first, else insert IDs 9001, 9002)
    DECLARE @City9001 INT = (SELECT TOP 1 CityID FROM Application.Cities WHERE CityName = N'Seattle Test');
    IF @City9001 IS NULL
    BEGIN
        SET @City9001 = COALESCE((SELECT CityID FROM Application.Cities WHERE CityID = 9001), 9001);
        IF NOT EXISTS (SELECT 1 FROM Application.Cities WHERE CityID = @City9001)
            INSERT INTO Application.Cities (CityID, CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
            VALUES (@City9001, N'Seattle Test', @StateProvinceID, 750000, @ActorPersonID);
    END;

    DECLARE @City9002 INT = (SELECT TOP 1 CityID FROM Application.Cities WHERE CityName = N'Portland Test');
    IF @City9002 IS NULL
    BEGIN
        SET @City9002 = COALESCE((SELECT CityID FROM Application.Cities WHERE CityID = 9002), 9002);
        IF NOT EXISTS (SELECT 1 FROM Application.Cities WHERE CityID = @City9002)
            INSERT INTO Application.Cities (CityID, CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
            VALUES (@City9002, N'Portland Test', @StateProvinceID, 640000, @ActorPersonID);
    END;

    -- DeliveryMethods (lookup by DeliveryMethodName first)
    DECLARE @DelivMethod901 INT = (SELECT TOP 1 DeliveryMethodID FROM Application.DeliveryMethods WHERE DeliveryMethodName = N'Refrigerated Truck');
    IF @DelivMethod901 IS NULL
    BEGIN
        SET @DelivMethod901 = COALESCE((SELECT MAX(DeliveryMethodID) + 1 FROM Application.DeliveryMethods), 901);
        IF @DelivMethod901 < 901 SET @DelivMethod901 = 901;
        INSERT INTO Application.DeliveryMethods (DeliveryMethodID, DeliveryMethodName, LastEditedBy)
        VALUES (@DelivMethod901, N'Refrigerated Truck', @ActorPersonID);
    END;

    DECLARE @DelivMethod902 INT = (SELECT TOP 1 DeliveryMethodID FROM Application.DeliveryMethods WHERE DeliveryMethodName = N'Courier Express');
    IF @DelivMethod902 IS NULL
    BEGIN
        SET @DelivMethod902 = COALESCE((SELECT MAX(DeliveryMethodID) + 1 FROM Application.DeliveryMethods), 902);
        IF @DelivMethod902 < 902 SET @DelivMethod902 = 902;
        INSERT INTO Application.DeliveryMethods (DeliveryMethodID, DeliveryMethodName, LastEditedBy)
        VALUES (@DelivMethod902, N'Courier Express', @ActorPersonID);
    END;

    -- TransactionTypes (lookup by TransactionTypeName first)
    DECLARE @TxType91 INT = (SELECT TOP 1 TransactionTypeID FROM Application.TransactionTypes WHERE TransactionTypeName = N'Stock Receipt (Test)');
    IF @TxType91 IS NULL
    BEGIN
        SET @TxType91 = COALESCE((SELECT MAX(TransactionTypeID) + 1 FROM Application.TransactionTypes), 91);
        IF @TxType91 < 91 SET @TxType91 = 91;
        INSERT INTO Application.TransactionTypes (TransactionTypeID, TransactionTypeName, LastEditedBy)
        VALUES (@TxType91, N'Stock Receipt (Test)', @ActorPersonID);
    END;

    DECLARE @TxType92 INT = (SELECT TOP 1 TransactionTypeID FROM Application.TransactionTypes WHERE TransactionTypeName = N'Stock Issue (Test)');
    IF @TxType92 IS NULL
    BEGIN
        SET @TxType92 = COALESCE((SELECT MAX(TransactionTypeID) + 1 FROM Application.TransactionTypes), 92);
        IF @TxType92 < 92 SET @TxType92 = 92;
        INSERT INTO Application.TransactionTypes (TransactionTypeID, TransactionTypeName, LastEditedBy)
        VALUES (@TxType92, N'Stock Issue (Test)', @ActorPersonID);
    END;

    -- SupplierCategories (lookup by SupplierCategoryName first)
    DECLARE @SupCat91 INT = (SELECT TOP 1 SupplierCategoryID FROM Purchasing.SupplierCategories WHERE SupplierCategoryName = N'Novelty & Merch');
    IF @SupCat91 IS NULL
    BEGIN
        SET @SupCat91 = COALESCE((SELECT MAX(SupplierCategoryID) + 1 FROM Purchasing.SupplierCategories), 91);
        IF @SupCat91 < 91 SET @SupCat91 = 91;
        INSERT INTO Purchasing.SupplierCategories (SupplierCategoryID, SupplierCategoryName, LastEditedBy)
        VALUES (@SupCat91, N'Novelty & Merch', @ActorPersonID);
    END;

    DECLARE @SupCat92 INT = (SELECT TOP 1 SupplierCategoryID FROM Purchasing.SupplierCategories WHERE SupplierCategoryName = N'Chilled Goods');
    IF @SupCat92 IS NULL
    BEGIN
        SET @SupCat92 = COALESCE((SELECT MAX(SupplierCategoryID) + 1 FROM Purchasing.SupplierCategories), 92);
        IF @SupCat92 < 92 SET @SupCat92 = 92;
        INSERT INTO Purchasing.SupplierCategories (SupplierCategoryID, SupplierCategoryName, LastEditedBy)
        VALUES (@SupCat92, N'Chilled Goods', @ActorPersonID);
    END;

    -- Colors (lookup by ColorName first)
    DECLARE @Color91 INT = (SELECT TOP 1 ColorID FROM Warehouse.Colors WHERE ColorName = N'Cobalt Blue');
    IF @Color91 IS NULL
    BEGIN
        SET @Color91 = COALESCE((SELECT MAX(ColorID) + 1 FROM Warehouse.Colors), 91);
        IF @Color91 < 91 SET @Color91 = 91;
        INSERT INTO Warehouse.Colors (ColorID, ColorName, LastEditedBy)
        VALUES (@Color91, N'Cobalt Blue', @ActorPersonID);
    END;

    DECLARE @Color92 INT = (SELECT TOP 1 ColorID FROM Warehouse.Colors WHERE ColorName = N'Crimson Red');
    IF @Color92 IS NULL
    BEGIN
        SET @Color92 = COALESCE((SELECT MAX(ColorID) + 1 FROM Warehouse.Colors), 92);
        IF @Color92 < 92 SET @Color92 = 92;
        INSERT INTO Warehouse.Colors (ColorID, ColorName, LastEditedBy)
        VALUES (@Color92, N'Crimson Red', @ActorPersonID);
    END;

    -- PackageTypes (lookup by PackageTypeName first -> avoids UQ_Warehouse_PackageTypes_PackageTypeName)
    DECLARE @PkgEach INT = (SELECT TOP 1 PackageTypeID FROM Warehouse.PackageTypes WHERE PackageTypeName = N'Each');
    IF @PkgEach IS NULL
    BEGIN
        SET @PkgEach = COALESCE((SELECT MAX(PackageTypeID) + 1 FROM Warehouse.PackageTypes), 91);
        IF @PkgEach < 91 SET @PkgEach = 91;
        INSERT INTO Warehouse.PackageTypes (PackageTypeID, PackageTypeName, LastEditedBy)
        VALUES (@PkgEach, N'Each', @ActorPersonID);
    END;

    DECLARE @PkgCarton INT = (SELECT TOP 1 PackageTypeID FROM Warehouse.PackageTypes WHERE PackageTypeName = N'Carton');
    IF @PkgCarton IS NULL
    BEGIN
        SET @PkgCarton = COALESCE((SELECT MAX(PackageTypeID) + 1 FROM Warehouse.PackageTypes), 92);
        IF @PkgCarton < 92 SET @PkgCarton = 92;
        INSERT INTO Warehouse.PackageTypes (PackageTypeID, PackageTypeName, LastEditedBy)
        VALUES (@PkgCarton, N'Carton', @ActorPersonID);
    END;

    -- StockGroups (lookup by StockGroupName first)
    DECLARE @Grp91 INT = (SELECT TOP 1 StockGroupID FROM Warehouse.StockGroups WHERE StockGroupName = N'T-Shirts');
    IF @Grp91 IS NULL
    BEGIN
        SET @Grp91 = COALESCE((SELECT MAX(StockGroupID) + 1 FROM Warehouse.StockGroups), 91);
        IF @Grp91 < 91 SET @Grp91 = 91;
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (@Grp91, N'T-Shirts', @ActorPersonID);
    END;

    DECLARE @Grp92 INT = (SELECT TOP 1 StockGroupID FROM Warehouse.StockGroups WHERE StockGroupName = N'Limited Edition');
    IF @Grp92 IS NULL
    BEGIN
        SET @Grp92 = COALESCE((SELECT MAX(StockGroupID) + 1 FROM Warehouse.StockGroups), 92);
        IF @Grp92 < 92 SET @Grp92 = 92;
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (@Grp92, N'Limited Edition', @ActorPersonID);
    END;

    DECLARE @Grp93 INT = (SELECT TOP 1 StockGroupID FROM Warehouse.StockGroups WHERE StockGroupName = N'Cold Chain');
    IF @Grp93 IS NULL
    BEGIN
        SET @Grp93 = COALESCE((SELECT MAX(StockGroupID) + 1 FROM Warehouse.StockGroups), 93);
        IF @Grp93 < 93 SET @Grp93 = 93;
        INSERT INTO Warehouse.StockGroups (StockGroupID, StockGroupName, LastEditedBy)
        VALUES (@Grp93, N'Cold Chain', @ActorPersonID);
    END;

    /* -------------------------------------------------------------------------
       1. Suppliers (IDs 901, 902)
       ------------------------------------------------------------------------- */
    IF OBJECTPROPERTY(OBJECT_ID(N'Purchasing.Suppliers'), 'TableHasIdentity') = 1
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
            901, N'Northwind Merch Supply', @SupCat91,
            @ActorPersonID, @ActorPersonID,
            @DelivMethod902, @City9001, @City9001,
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
            902, N'Cascade Frost Logistics', @SupCat92,
            @ActorPersonID, @ActorPersonID,
            @DelivMethod901, @City9002, @City9002,
            N'REF-CFL-902', N'Cascade Acct', N'West Branch', N'021000089',
            N'200902002', N'CFUS44', 14,
            N'(503) 555-0144', N'(503) 555-0145', N'https://cascade-frost.example.com',
            N'200 Burnside St', N'97209', N'PO Box 902', N'97209',
            @ActorPersonID
        );

    IF OBJECTPROPERTY(OBJECT_ID(N'Purchasing.Suppliers'), 'TableHasIdentity') = 1
        SET IDENTITY_INSERT Purchasing.Suppliers OFF;

    /* -------------------------------------------------------------------------
       2. StockItems (IDs 9001, 9002, 9003)
       ------------------------------------------------------------------------- */
    IF OBJECTPROPERTY(OBJECT_ID(N'Warehouse.StockItems'), 'TableHasIdentity') = 1
        SET IDENTITY_INSERT Warehouse.StockItems ON;

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItems WHERE StockItemID = 9001)
        INSERT INTO Warehouse.StockItems (
            StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
            Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode,
            TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, LastEditedBy
        )
        VALUES (
            9001, N'WWI Developer Tee (Cobalt)', 901, @Color91, @PkgEach, @PkgCarton,
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
            9002, N'Artisan Chilled Gel Pack', 902, @Color92, @PkgEach, @PkgCarton,
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
            9003, N'Unclassified Test Widget', 901, NULL, @PkgEach, @PkgEach,
            NULL, N'Standard', 14, 1, 0, NULL,
            15.000, 12.00, 18.00, 0.100, @ActorPersonID
        );

    IF OBJECTPROPERTY(OBJECT_ID(N'Warehouse.StockItems'), 'TableHasIdentity') = 1
        SET IDENTITY_INSERT Warehouse.StockItems OFF;

    /* -------------------------------------------------------------------------
       3. StockItemStockGroups (9001 has 2 groups; 9002 has 1; 9003 has 0)
       ------------------------------------------------------------------------- */
    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9001 AND StockGroupID = @Grp91)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9001, @Grp91, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9001 AND StockGroupID = @Grp92)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9001, @Grp92, @ActorPersonID);

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemStockGroups WHERE StockItemID = 9002 AND StockGroupID = @Grp93)
        INSERT INTO Warehouse.StockItemStockGroups (StockItemID, StockGroupID, LastEditedBy)
        VALUES (9002, @Grp93, @ActorPersonID);

    /* -------------------------------------------------------------------------
       4. StockItemHoldings (PK = StockItemID)
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
       ------------------------------------------------------------------------- */
    IF OBJECTPROPERTY(OBJECT_ID(N'Warehouse.StockItemTransactions'), 'TableHasIdentity') = 1
        SET IDENTITY_INSERT Warehouse.StockItemTransactions ON;

    IF NOT EXISTS (SELECT 1 FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID = 90001)
        INSERT INTO Warehouse.StockItemTransactions (
            StockItemTransactionID, StockItemID, TransactionTypeID,
            CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
            TransactionOccurredWhen, Quantity, LastEditedBy
        )
        VALUES (
            90001, 9001, @TxType91,
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
            90002, 9001, @TxType92,
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
            90003, 9002, @TxType91,
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
            90004, 9003, @TxType91,
            NULL, NULL, NULL, NULL,
            '2026-11-20T16:45:00', 30.000, @ActorPersonID
        );

    IF OBJECTPROPERTY(OBJECT_ID(N'Warehouse.StockItemTransactions'), 'TableHasIdentity') = 1
        SET IDENTITY_INSERT Warehouse.StockItemTransactions OFF;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

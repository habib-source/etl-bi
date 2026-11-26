USE WideWorldImporters;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM Warehouse.StockItemTransactions
    WHERE StockItemTransactionID BETWEEN 90001 AND 90004;

    DELETE FROM Warehouse.StockItemHoldings
    WHERE StockItemID BETWEEN 9001 AND 9003;

    DELETE FROM Warehouse.StockItemStockGroups
    WHERE StockItemID BETWEEN 9001 AND 9003;

    DELETE FROM Warehouse.StockItems
    WHERE StockItemID BETWEEN 9001 AND 9003;

    DELETE FROM Purchasing.Suppliers
    WHERE SupplierID BETWEEN 901 AND 902;

    -- Delete only test-specific lookup/reference rows (safe if none were inserted)
    DELETE FROM Warehouse.StockGroups
    WHERE StockGroupName IN (N'T-Shirts', N'Limited Edition', N'Cold Chain')
      AND StockGroupID >= 91;

    DELETE FROM Warehouse.PackageTypes
    WHERE PackageTypeName IN (N'Each', N'Carton')
      AND PackageTypeID >= 91;

    DELETE FROM Warehouse.Colors
    WHERE ColorName IN (N'Cobalt Blue', N'Crimson Red')
      AND ColorID >= 91;

    DELETE FROM Purchasing.SupplierCategories
    WHERE SupplierCategoryName IN (N'Novelty & Merch', N'Chilled Goods')
      AND SupplierCategoryID >= 91;

    DELETE FROM Application.TransactionTypes
    WHERE TransactionTypeName IN (N'Stock Receipt (Test)', N'Stock Issue (Test)')
      AND TransactionTypeID >= 91;

    DELETE FROM Application.DeliveryMethods
    WHERE DeliveryMethodName IN (N'Refrigerated Truck', N'Courier Express')
      AND DeliveryMethodID >= 901;

    DELETE FROM Application.Cities
    WHERE CityName IN (N'Seattle Test', N'Portland Test')
      AND CityID >= 9001;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

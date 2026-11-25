USE WideWorldImporters;
GO

DELETE FROM Warehouse.StockItemTransactions WHERE StockItemTransactionID BETWEEN 90001 AND 90004;
DELETE FROM Warehouse.StockItemHoldings WHERE StockItemID BETWEEN 9001 AND 9003;
DELETE FROM Warehouse.StockItemStockGroups WHERE StockItemID BETWEEN 9001 AND 9003 OR StockGroupID BETWEEN 91 AND 93;
DELETE FROM Warehouse.StockItems WHERE StockItemID BETWEEN 9001 AND 9003;
DELETE FROM Purchasing.Suppliers WHERE SupplierID BETWEEN 901 AND 902;
DELETE FROM Warehouse.StockGroups WHERE StockGroupID BETWEEN 91 AND 93;
DELETE FROM Warehouse.PackageTypes WHERE PackageTypeID BETWEEN 91 AND 92;
DELETE FROM Warehouse.Colors WHERE ColorID BETWEEN 91 AND 92;
DELETE FROM Purchasing.SupplierCategories WHERE SupplierCategoryID BETWEEN 91 AND 92;
DELETE FROM Application.TransactionTypes WHERE TransactionTypeID BETWEEN 91 AND 92;
DELETE FROM Application.DeliveryMethods WHERE DeliveryMethodID BETWEEN 901 AND 902;
DELETE FROM Application.Cities WHERE CityID BETWEEN 9001 AND 9002;
GO

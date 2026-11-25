Changed database context to 'WideWorldImporters'.
TableName Columns
--------- -------
Application.Cities CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
Application.Cities_Archive CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
Application.Countries CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType, LatestRecordedPopulation, Continent, Region, Subregion, Border, LastEditedBy, ValidFrom, ValidTo
Application.Countries_Archive CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType, LatestRecordedPopulation, Continent, Region, Subregion, Border, LastEditedBy, ValidFrom, ValidTo
Application.DeliveryMethods DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
Application.DeliveryMethods_Archive DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo
Application.PaymentMethods PaymentMethodID, PaymentMethodName, LastEditedBy, ValidFrom, ValidTo
Application.PaymentMethods_Archive PaymentMethodID, PaymentMethodName, LastEditedBy, ValidFrom, ValidTo
Application.People PersonID, FullName, PreferredName, SearchName, IsPermittedToLogon, LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser, IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber, EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo
Application.People_Archive PersonID, FullName, PreferredName, SearchName, IsPermittedToLogon, LogonName, IsExternalLogonProvider, HashedPassword, IsSystemUser, IsEmployee, IsSalesperson, UserPreferences, PhoneNumber, FaxNumber, EmailAddress, Photo, CustomFields, OtherLanguages, LastEditedBy, ValidFrom, ValidTo
Application.StateProvinces StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
Application.StateProvinces_Archive StateProvinceID, StateProvinceCode, StateProvinceName, CountryID, SalesTerritory, Border, LatestRecordedPopulation, LastEditedBy, ValidFrom, ValidTo
Application.SystemParameters SystemParameterID, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryCityID, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalCityID, PostalPostalCode, ApplicationSettings, LastEditedBy, LastEditedWhen
Application.TransactionTypes TransactionTypeID, TransactionTypeName, LastEditedBy, ValidFrom, ValidTo
Application.TransactionTypes_Archive TransactionTypeID, TransactionTypeName, LastEditedBy, ValidFrom, ValidTo
Purchasing.PurchaseOrderLines PurchaseOrderLineID, PurchaseOrderID, StockItemID, OrderedOuters, Description, ReceivedOuters, PackageTypeID, ExpectedUnitPricePerOuter, LastReceiptDate, IsOrderLineFinalized, LastEditedBy, LastEditedWhen
Purchasing.PurchaseOrders PurchaseOrderID, SupplierID, OrderDate, DeliveryMethodID, ContactPersonID, ExpectedDeliveryDate, SupplierReference, IsOrderFinalized, Comments, InternalComments, LastEditedBy, LastEditedWhen
Purchasing.SupplierCategories SupplierCategoryID, SupplierCategoryName, LastEditedBy, ValidFrom, ValidTo
Purchasing.SupplierCategories_Archive SupplierCategoryID, SupplierCategoryName, LastEditedBy, ValidFrom, ValidTo
Purchasing.Suppliers SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
Purchasing.Suppliers_Archive SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
Purchasing.SupplierTransactions SupplierTransactionID, SupplierID, TransactionTypeID, PurchaseOrderID, PaymentMethodID, SupplierInvoiceNumber, TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount, OutstandingBalance, FinalizationDate, IsFinalized, LastEditedBy, LastEditedWhen
Sales.BuyingGroups BuyingGroupID, BuyingGroupName, LastEditedBy, ValidFrom, ValidTo
Sales.BuyingGroups_Archive BuyingGroupID, BuyingGroupName, LastEditedBy, ValidFrom, ValidTo
Sales.CustomerCategories CustomerCategoryID, CustomerCategoryName, LastEditedBy, ValidFrom, ValidTo
Sales.CustomerCategories_Archive CustomerCategoryID, CustomerCategoryName, LastEditedBy, ValidFrom, ValidTo
Sales.Customers CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
Sales.Customers_Archive CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
Sales.CustomerTransactions CustomerTransactionID, CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID, TransactionDate, AmountExcludingTax, TaxAmount, TransactionAmount, OutstandingBalance, FinalizationDate, IsFinalized, LastEditedBy, LastEditedWhen
Sales.InvoiceLines InvoiceLineID, InvoiceID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen
Sales.Invoices InvoiceID, CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID, AccountsPersonID, SalespersonPersonID, PackedByPersonID, InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason, Comments, DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems, DeliveryRun, RunPosition, ReturnedDeliveryData, ConfirmedDeliveryTime, ConfirmedReceivedBy, LastEditedBy, LastEditedWhen
Sales.OrderLines OrderLineID, OrderID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy, LastEditedWhen
Sales.Orders OrderID, CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonID, BackorderOrderID, OrderDate, ExpectedDeliveryDate, CustomerPurchaseOrderNumber, IsUndersupplyBackordered, Comments, DeliveryInstructions, InternalComments, PickingCompletedWhen, LastEditedBy, LastEditedWhen
Sales.SpecialDeals SpecialDealID, StockItemID, CustomerID, BuyingGroupID, CustomerCategoryID, StockGroupID, DealDescription, StartDate, EndDate, DiscountAmount, DiscountPercentage, UnitPrice, LastEditedBy, LastEditedWhen
Warehouse.ColdRoomTemperatures ColdRoomTemperatureID, ColdRoomSensorNumber, RecordedWhen, Temperature, ValidFrom, ValidTo
Warehouse.ColdRoomTemperatures_Archive ColdRoomTemperatureID, ColdRoomSensorNumber, RecordedWhen, Temperature, ValidFrom, ValidTo
Warehouse.Colors ColorID, ColorName, LastEditedBy, ValidFrom, ValidTo
Warehouse.Colors_Archive ColorID, ColorName, LastEditedBy, ValidFrom, ValidTo
Warehouse.PackageTypes PackageTypeID, PackageTypeName, LastEditedBy, ValidFrom, ValidTo
Warehouse.PackageTypes_Archive PackageTypeID, PackageTypeName, LastEditedBy, ValidFrom, ValidTo
Warehouse.StockGroups StockGroupID, StockGroupName, LastEditedBy, ValidFrom, ValidTo
Warehouse.StockGroups_Archive StockGroupID, StockGroupName, LastEditedBy, ValidFrom, ValidTo
Warehouse.StockItemHoldings StockItemID, QuantityOnHand, BinLocation, LastStocktakeQuantity, LastCostPrice, ReorderLevel, TargetStockLevel, LastEditedBy, LastEditedWhen
Warehouse.StockItems StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID, Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, MarketingComments, InternalComments, Photo, CustomFields, Tags, SearchDetails, LastEditedBy, ValidFrom, ValidTo
Warehouse.StockItems_Archive StockItemID, StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID, Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, MarketingComments, InternalComments, Photo, CustomFields, Tags, SearchDetails, LastEditedBy, ValidFrom, ValidTo
Warehouse.StockItemStockGroups StockItemStockGroupID, StockItemID, StockGroupID, LastEditedBy, LastEditedWhen
Warehouse.StockItemTransactions StockItemTransactionID, StockItemID, TransactionTypeID, CustomerID, InvoiceID, SupplierID, PurchaseOrderID, TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen
Warehouse.VehicleTemperatures VehicleTemperatureID, VehicleRegistration, ChillerSensorNumber, RecordedWhen, Temperature, FullSensorData, IsCompressed, CompressedSensorData
Website.Customers CustomerID, CustomerName, CustomerCategoryName, PrimaryContact, AlternateContact, PhoneNumber, FaxNumber, BuyingGroupName, WebsiteURL, DeliveryMethod, CityName, DeliveryLocation, DeliveryRun, RunPosition
Website.Suppliers SupplierID, SupplierName, SupplierCategoryName, PrimaryContact, AlternateContact, PhoneNumber, FaxNumber, WebsiteURL, DeliveryMethod, CityName, DeliveryLocation, SupplierReference
Website.VehicleTemperatures VehicleTemperatureID, VehicleRegistration, ChillerSensorNumber, RecordedWhen, Temperature, FullSensorData

(51 rows affected)

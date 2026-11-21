SET NOCOUNT ON;
IF DB_ID('WideWorldImporters') IS NULL
BEGIN
    RESTORE DATABASE WideWorldImporters
    FROM DISK = '/var/opt/mssql/WideWorldImporters-Full.bak'
    WITH
        MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf',
        MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
        MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters_log.ldf',
        MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1';
END
GO

#!/bin/bash
set -e

until /opt/mssql-tools18/bin/sqlcmd -S data-warehouse -U sa -P "$MSSQL_SA_PASSWORD" -C -b -Q "SET NOCOUNT ON; IF DB_ID(N'WideWorldImportersDW') IS NULL RAISERROR('Database not ready', 16, 1);" &> /dev/null
do
    sleep 2
    echo "Waiting ..."
done

echo "SQL Server is up. Restoring database..."

echo "Database migration:"
echo "-----------------------------------"
echo "-----------------------------------"
mssqldef -h data-warehouse -p 1433 -U sa -P "$MSSQL_SA_PASSWORD" WideWorldImportersDW --apply < schema.sql

exec "$@"

From mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04
USER root
RUN apt-get update && apt-get install -y curl
RUN mkdir /mssql-server-setup-scripts.d
USER mssql
RUN curl -L -o /var/opt/mssql/WideWorldImporters-Full.bak "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"
COPY ./restore.sql /mssql-server-setup-scripts.d/restore.sql

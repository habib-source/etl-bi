From mcr.microsoft.com/mssql/server:2025-CU9-ubuntu-24.04
USER root
RUN apt-get update && apt-get install -y wget

RUN wget -O - https://github.com/sqldef/sqldef/releases/latest/download/mssqldef_linux_amd64.tar.gz \
	| tar xvz && mv mssqldef /usr/local/bin/
RUN mkdir /mssql-server-setup-scripts.d
COPY ./schema.sql .
COPY --chmod=+x ./entrypoint.sh .
USER mssql

.PHONY: etl-run db-pp etl-test clean-db

SPARK_CONTAINER ?= spark-runner
SPARK_MASTER    ?= spark://spark:7077
MSSQL_JDBC_PKG  ?= com.microsoft.sqlserver:mssql-jdbc:13.6.2.jre11
ETL_SCRIPT      ?= src/etl.py

DB_CONTAINER    ?= wide-world-importers-db
SQLCMD          ?= /opt/mssql-tools18/bin/sqlcmd
DB_HOST         ?= localhost
DB_USER         ?= sa
DB_PASS         ?= Dev4oddJob
DB_NAME         ?= WideWorldImporters

# Use -it only when both stdin and stdout are attached to a TTY (safe for CI/CD and pipes)
TTY := $(shell if [ -t 0 ] && [ -t 1 ]; then echo "-it"; else echo "-i"; fi)

etl-run:
	docker exec $(TTY) $(SPARK_CONTAINER) /opt/spark/bin/spark-submit \
		--master $(SPARK_MASTER) \
		--packages $(MSSQL_JDBC_PKG) \
		--conf spark.jars.ivy=/tmp/.ivy2 \
		$(ETL_SCRIPT)

db-pp:
	docker exec $(TTY) $(DB_CONTAINER) $(SQLCMD) \
		-S $(DB_HOST) -U $(DB_USER) -P "$(DB_PASS)" -d $(DB_NAME) -C -W \
		-Q "SELECT TABLE_SCHEMA + '.' + TABLE_NAME AS TableName, STRING_AGG(COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) AS Columns FROM INFORMATION_SCHEMA.COLUMNS GROUP BY TABLE_SCHEMA, TABLE_NAME ORDER BY TABLE_SCHEMA, TABLE_NAME;"

etl-test:
	docker exec -i $(DB_CONTAINER) $(SQLCMD) \
		-S $(DB_HOST) -U $(DB_USER) -P "$(DB_PASS)" -d $(DB_NAME) -C -b -W < ./test/seed_wwi.sql

clean-db:
	docker exec -i $(DB_CONTAINER) $(SQLCMD) \
		-S $(DB_HOST) -U $(DB_USER) -P "$(DB_PASS)" -d $(DB_NAME) -C -b -W < ./test/cleanup_wwi.sql

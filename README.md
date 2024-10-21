# Project Description
This project streams static data from kafka to PostgreSQL database, utilizing the following tools:
- PostgreSQL
- Kafka
- Kafka Connect
- Schema Registry
- KSQL

No programming language was employed because the entire pipeline can be set up within the Kafka framework.
## Setup and Configuration
### 1. Starting Services:
Begin by ensuring all the services are up and running with the following command:
   ``` bash 
   docker compose up -d 
   ```
After executing this, confirm every service is active. If any service (like KSQL or schema-registry) faces issues, the ETL process will not operate correctly. Also, check for any Out Of Memory (OOM) errors from Docker.
To inspect, for instance, the ksql server logs:
   ``` bash
   docker logs ksql-server
   ```
### 2. Data Ingestion:
Once all services are verified to be working, execute the following commands to produce data into Kafka topics:
   ```bash 
   docker-compose exec kafka /bin/bash -c 'cat data-files/jobs.kafka | kafka-console-producer.sh --bootstrap-server localhost:9092 --property parse.key=true --property key.separator="|" --topic jobs_json'
   ```
   ``` bash 
   docker-compose exec kafka /bin/bash -c 'cat data-files/users.ndjson | kafka-console-producer.sh --bootstrap-server localhost:9092 --property parse.key=false --topic users_json'
   ```
### 3. KSQL Processing:
Next, connect to the KSQL server and execute the necessary commands:
   ``` bash 
   docker-compose exec ksql-server bash -c 'cat /ksql-commands/commands.sql <(echo -e ; -e '\nEXIT') | ksql http://ksql-server:8088'
   ```
This command instructs KSQL to create streams for both users and jobs. It then transmits them to another topic utilizing avro serialization. Following this, KSQL sets up JDBC Sink Connectors for both users and jobs, which deserialize the data with the avro schema and upsert it into PostgreSQL tables predefined by the postgres service.
The rationale behind using KSQL for the creation of JDBC Sink Connectors was to avoid sending POST requests to the Kafka Connect server directly from local terminal.
### 4. Query Execution:
Before moving forward to query execution, wait for several seconds so that JDBC Sink Connector can write data into PostgreSQL database.
The necessary query for the project outcome is embedded within the postgres service. To run the query, provide the desired location as a parameter:
   ``` bash 
   docker-compose exec postgres psql -U postgres -d postgres -v LOCATION='LOC_1295' -f /postgres-query/query.sql
   ```
This command retrieves a maximum of five users who haven't registered at a job's location, ordered by the highest revenue generated. Note: jobs that return NO_SUCCESS should not be considered revenue-generating.

SET 'auto.offset.reset' = 'earliest';

CREATE STREAM jobs (JOBCREATEDATE VARCHAR, JOBDATE VARCHAR, JOBIDENTIFIER INT, JOBSTATUS VARCHAR, LOCATION VARCHAR, REVENUE DOUBLE, SERVICENAME VARCHAR, USERID BIGINT) WITH (KAFKA_TOPIC='jobs_json', VALUE_FORMAT='JSON');

CREATE STREAM users (USERID BIGINT, LOCATION VARCHAR) WITH (KAFKA_TOPIC='users_json', VALUE_FORMAT='JSON');

CREATE STREAM jobs_avro WITH (VALUE_FORMAT='AVRO', KAFKA_TOPIC='jobs') AS SELECT * FROM jobs;

CREATE STREAM users_avro WITH (VALUE_FORMAT='AVRO', KAFKA_TOPIC='users') AS SELECT * FROM users;

CREATE SINK CONNECTOR POSTGRES_SINK_JOBS WITH (
'connector.class'= 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max'= '2',
'topics'= 'jobs',
'key.converter'= 'org.apache.kafka.connect.storage.StringConverter',
'value.converter'= 'io.confluent.connect.avro.AvroConverter',
'key.converter.schema.registry.url'= 'http://schema-registry:8081',
'value.converter.schema.registry.url'= 'http://schema-registry:8081',
'connection.url'= 'jdbc:postgresql://postgres:5432/postgres?stringtype=unspecified',
'connection.user'= 'postgres',
'connection.password'= 'postgres',
'key.converter.schemas.enable'= 'false',
'value.converter.schemas.enable'= 'true',
'key.ignore'= 'true',
'auto.create'= 'true',
'auto.evolve'= 'true',
'insert.mode'= 'upsert',
'pk.fields'= 'JOBIDENTIFIER',
'pk.mode'= 'record_key',
'transforms'= 'ValueToKey',
'transforms.ValueToKey.type'= 'org.apache.kafka.connect.transforms.ValueToKey',
'transforms.ValueToKey.fields'= 'JOBCREATEDATE,JOBDATE,JOBIDENTIFIER,JOBSTATUS,LOCATION,REVENUE,SERVICENAME,USERID');

CREATE SINK CONNECTOR POSTGRES_SINK_USERS WITH (
'connector.class'= 'io.confluent.connect.jdbc.JdbcSinkConnector',
'tasks.max'= '2',
'topics'= 'users',
'key.converter'='org.apache.kafka.connect.storage.StringConverter',
'value.converter'= 'io.confluent.connect.avro.AvroConverter',
'key.converter.schema.registry.url'= 'http://schema-registry:8081',
'value.converter.schema.registry.url'= 'http://schema-registry:8081',
'connection.url'= 'jdbc:postgresql://postgres:5432/postgres?stringtype=unspecified',
'connection.user'= 'postgres',
'connection.password'= 'postgres',
'key.converter.schemas.enable'='false',
'value.converter.schemas.enable'='true',
'key.ignore'= 'true',
'auto.create'= 'true',
'auto.evolve'= 'true',
'insert.mode'= 'upsert',
'pk.fields'= 'USERID',
'pk.mode'= 'record_key',
'transforms'= 'ValueToKey',
'transforms.ValueToKey.type'= 'org.apache.kafka.connect.transforms.ValueToKey',
'transforms.ValueToKey.fields'= 'USERID,LOCATION');
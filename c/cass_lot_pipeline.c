#include <cassandra.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#define NUM_SENSORS 1000
#define NUM_THREADS 10
#define NUM_RECORDS 100000

// Structure for sensor data
typedef struct {
    CassUuid sensor_id;
    char sensor_name[50];
    char sensor_type[20];
    double latitude;
    double longitude;
} SensorMetadata;

// Structure for sensor readings
typedef struct {
    CassUuid sensor_id;
    cass_int64_t timestamp;
    double value;
    int status;
} SensorReading;

// Global variables
SensorMetadata sensors[NUM_SENSORS];
CassCluster* cluster = NULL;
CassSession* session = NULL;

// Initialize the Cassandra driver and connect to the cluster
void init_cassandra() {
    cluster = cass_cluster_new();
    session = cass_session_new();
    
    // Add contact points
    cass_cluster_set_contact_points(cluster, "127.0.0.1");  // Replace with your node IPs
    
    // Set protocol version (adjust based on your Cassandra version)
    cass_cluster_set_protocol_version(cluster, CASS_PROTOCOL_VERSION_V4);
    
    // Connect to the cluster
    CassFuture* connect_future = cass_session_connect(session, cluster);
    
    if (cass_future_error_code(connect_future) != CASS_OK) {
        const char* message;
        size_t message_length;
        cass_future_error_message(connect_future, &message, &message_length);
        fprintf(stderr, "Unable to connect: '%.*s'\n", (int)message_length, message);
        exit(1);
    }
    
    cass_future_free(connect_future);
    printf("Connected to Cassandra cluster successfully!\n");
}

// Generate random sensor data
void generate_sensor_data() {
    for (int i = 0; i < NUM_SENSORS; i++) {
        cass_uuid_generate_random(sensors[i].sensor_id);
        sprintf(sensors[i].sensor_name, "sensor-%04d", i);
        
        // Random sensor type
        const char* types[] = {"temperature", "humidity", "pressure", "voltage", "current"};
        strcpy(sensors[i].sensor_type, types[rand() % 5]);
        
        // Random location
        sensors[i].latitude = 34.0 + ((double)rand() / RAND_MAX) * 6.0;  // 34-40 latitude
        sensors[i].longitude = -118.0 + ((double)rand() / RAND_MAX) * 10.0;  // -118 to -108 longitude
    }
}

// Insert sensor metadata
void insert_sensor_metadata() {
    const char* query = "INSERT INTO sensor_network.sensors (sensor_id, name, type, latitude, longitude) VALUES (?, ?, ?, ?, ?)";
    
    for (int i = 0; i < NUM_SENSORS; i++) {
        CassStatement* statement = cass_statement_new(query, 5);
        
        cass_statement_bind_uuid(statement, 0, sensors[i].sensor_id);
        cass_statement_bind_string(statement, 1, sensors[i].sensor_name);
        cass_statement_bind_string(statement, 2, sensors[i].sensor_type);
        cass_statement_bind_double(statement, 3, sensors[i].latitude);
        cass_statement_bind_double(statement, 4, sensors[i].longitude);
        
        CassFuture* future = cass_session_execute(session, statement);
        cass_future_wait(future);
        
        if (cass_future_error_code(future) != CASS_OK) {
            const char* message;
            size_t message_length;
            cass_future_error_message(future, &message, &message_length);
            fprintf(stderr, "Error inserting sensor metadata: '%.*s'\n", (int)message_length, message);
        }
        
        cass_statement_free(statement);
        cass_future_free(future);
    }
    
    printf("Inserted %d sensor metadata records\n", NUM_SENSORS);
}

// Thread function to insert sensor readings
void* insert_sensor_readings_thread(void* thread_id) {
    long tid = (long)thread_id;
    int readings_per_thread = NUM_RECORDS / NUM_THREADS;
    
    const char* query = "INSERT INTO sensor_network.readings (sensor_id, timestamp, value, status) VALUES (?, ?, ?, ?) USING TTL 2592000"; // 30 days TTL
    
    for (int i = 0; i < readings_per_thread; i++) {
        // Random sensor
        int sensor_idx = rand() % NUM_SENSORS;
        
        // Current timestamp in milliseconds
        cass_int64_t timestamp = (cass_int64_t)time(NULL) * 1000;
        
        // Random value based on sensor type
        double value;
        if (strcmp(sensors[sensor_idx].sensor_type, "temperature") == 0) {
            value = 20.0 + ((double)rand() / RAND_MAX) * 30.0; // 20-50°C
        } else if (strcmp(sensors[sensor_idx].sensor_type, "humidity") == 0) {
            value = 30.0 + ((double)rand() / RAND_MAX) * 70.0; // 30-100%
        } else if (strcmp(sensors[sensor_idx].sensor_type, "pressure") == 0) {
            value = 980.0 + ((double)rand() / RAND_MAX) * 40.0; // 980-1020 hPa
        } else if (strcmp(sensors[sensor_idx].sensor_type, "voltage") == 0) {
            value = 110.0 + ((double)rand() / RAND_MAX) * 10.0; // 110-120V
        } else { // current
            value = 0.1 + ((double)rand() / RAND_MAX) * 15.0; // 0.1-15A
        }
        
        // Random status (0=normal, 1=warning, 2=alert)
        int status = rand() % 20 == 0 ? 2 : (rand() % 10 == 0 ? 1 : 0);
        
        CassStatement* statement = cass_statement_new(query, 4);
        
        cass_statement_bind_uuid(statement, 0, sensors[sensor_idx].sensor_id);
        cass_statement_bind_int64(statement, 1, timestamp);
        cass_statement_bind_double(statement, 2, value);
        cass_statement_bind_int32(statement, 3, status);
        
        CassFuture* future = cass_session_execute(session, statement);
        
        // For high throughput, we don't wait for each insert to complete
        // In a real application, you'd use proper async handling with callbacks
        if (i % 1000 == 0) {
            cass_future_wait(future);
            if (cass_future_error_code(future) != CASS_OK) {
                const char* message;
                size_t message_length;
                cass_future_error_message(future, &message, &message_length);
                fprintf(stderr, "Error in thread %ld: '%.*s'\n", tid, (int)message_length, message);
            }
        }
        
        cass_statement_free(statement);
        cass_future_free(future);
    }
    
    printf("Thread %ld completed: inserted %d readings\n", tid, readings_per_thread);
    pthread_exit(NULL);
}

// Query to find sensors with recent alerts
void query_recent_alerts() {
    printf("\nQuerying for recent alerts...\n");
    
    // Get timestamp for 1 hour ago
    cass_int64_t one_hour_ago = (cass_int64_t)(time(NULL) - 3600) * 1000;
    
    const char* query = "SELECT sensor_id, timestamp, value FROM sensor_network.readings WHERE status = 2 AND timestamp > ? LIMIT 10";
    
    CassStatement* statement = cass_statement_new(query, 1);
    cass_statement_bind_int64(statement, 0, one_hour_ago);
    
    CassFuture* future = cass_session_execute(session, statement);
    cass_future_wait(future);
    
    if (cass_future_error_code(future) != CASS_OK) {
        const char* message;
        size_t message_length;
        cass_future_error_message(future, &message, &message_length);
        fprintf(stderr, "Query failed: '%.*s'\n", (int)message_length, message);
    } else {
        const CassResult* result = cass_future_get_result(future);
        CassIterator* iterator = cass_iterator_from_result(result);
        
        printf("Recent alerts:\n");
        while (cass_iterator_next(iterator)) {
            const CassRow* row = cass_iterator_get_row(iterator);
            
            CassUuid sensor_id;
            cass_value_get_uuid(cass_row_get_column(row, 0), &sensor_id);
            
            cass_int64_t timestamp;
            cass_value_get_int64(cass_row_get_column(row, 1), &timestamp);
            
            double value;
            cass_value_get_double(cass_row_get_column(row, 2), &value);
            
            char sensor_id_str[CASS_UUID_STRING_LENGTH];
            cass_uuid_string(sensor_id, sensor_id_str);
            
            printf("Sensor: %s, Time: %lld, Value: %.2f\n", 
                   sensor_id_str, (long long)timestamp, value);
        }
        
        cass_iterator_free(iterator);
        cass_result_free(result);
    }
    
    cass_statement_free(statement);
    cass_future_free(future);
}

// Create the keyspace and tables
void create_schema() {
    const char* create_keyspace = 
        "CREATE KEYSPACE IF NOT EXISTS sensor_network WITH replication = {"
        "'class': 'NetworkTopologyStrategy', "
        "'datacenter1': 3} AND durable_writes = true";
    
    const char* create_sensors_table = 
        "CREATE TABLE IF NOT EXISTS sensor_network.sensors ("
        "sensor_id UUID PRIMARY KEY, "
        "name TEXT, "
        "type TEXT, "
        "latitude DOUBLE, "
        "longitude DOUBLE)";
    
    const char* create_readings_table = 
        "CREATE TABLE IF NOT EXISTS sensor_network.readings ("
        "sensor_id UUID, "
        "timestamp BIGINT, "
        "value DOUBLE, "
        "status INT, "
        "PRIMARY KEY ((sensor_id), timestamp)) "
        "WITH CLUSTERING ORDER BY (timestamp DESC)";
    
    const char* create_alerts_table = 
        "CREATE TABLE IF NOT EXISTS sensor_network.alerts_by_severity ("
        "severity INT, "
        "timestamp BIGINT, "
        "sensor_id UUID, "
        "value DOUBLE, "
        "PRIMARY KEY ((severity), timestamp, sensor_id)) "
        "WITH CLUSTERING ORDER BY (timestamp DESC)";
    
    // Execute the schema creation queries
    CassStatement* statement;
    CassFuture* future;
    
    statement = cass_statement_new(create_keyspace, 0);
    future = cass_session_execute(session, statement);
    cass_future_wait(future);
    cass_statement_free(statement);
    cass_future_free(future);
    
    statement = cass_statement_new(create_sensors_table, 0);
    future = cass_session_execute(session, statement);
    cass_future_wait(future);
    cass_statement_free(statement);
    cass_future_free(future);
    
    statement = cass_statement_new(create_readings_table, 0);
    future = cass_session_execute(session, statement);
    cass_future_wait(future);
    cass_statement_free(statement);
    cass_future_free(future);
    
    statement = cass_statement_new(create_alerts_table, 0);
    future = cass_session_execute(session, statement);
    cass_future_wait(future);
    cass_statement_free(statement);
    cass_future_free(future);
    
    printf("Schema created successfully!\n");
}

int main() {
    srand(time(NULL));
    
    // Initialize Cassandra connection
    init_cassandra();
    
    // Create the schema
    create_schema();
    
    // Generate and insert sensor metadata
    generate_sensor_data();
    insert_sensor_metadata();
    
    // Create threads for concurrent writes
    pthread_t threads[NUM_THREADS];
    int rc;
    long t;
    
    printf("Starting %d threads to insert %d sensor readings...\n", NUM_THREADS, NUM_RECORDS);
    
    clock_t start = clock();
    
    for (t = 0; t < NUM_THREADS; t++) {
        rc = pthread_create(&threads[t], NULL, insert_sensor_readings_thread, (void*)t);
        if (rc) {
            printf("Error: unable to create thread, %d\n", rc);
            exit(-1);
        }
    }
    
    // Wait for all threads to complete
    for (t = 0; t < NUM_THREADS; t++) {
        pthread_join(threads[t], NULL);
    }
    
    clock_t end = clock();
    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    
    printf("All threads completed in %.2f seconds\n", time_spent);
    printf("Throughput: %.2f writes/second\n", NUM_RECORDS / time_spent);
    
    // Query for recent alerts
    query_recent_alerts();
    
    // Clean up
    cass_session_free(session);
    cass_cluster_free(cluster);
    
    return 0;
}
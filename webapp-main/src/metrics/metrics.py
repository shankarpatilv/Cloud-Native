from statsd import StatsClient
import time

statsd_client = StatsClient('localhost', 8125)

def count_api_call(endpoint_name):
    """Count the number of times an API is called."""
    statsd_client.incr(f"api.{endpoint_name}.count")

def time_api_call(endpoint_name, duration):
    """Measure the duration of an API call."""
    statsd_client.timing(f"api.{endpoint_name}.duration", duration)

def time_db_query(duration):
    """Measure the duration of a database query."""
    statsd_client.timing("db.query.duration", duration)

def time_s3_call(operation, duration):
    """Measure the duration of an S3 operation (e.g., upload, delete)."""
    statsd_client.timing(f"s3.{operation}.duration", duration)

class Timer:
    def __init__(self, metric_name):
        self.metric_name = metric_name
        self.start_time = None

    def __enter__(self):
        self.start_time = time.time()

    def __exit__(self, exc_type, exc_val, exc_tb):
        duration = (time.time() - self.start_time) * 1000  
        statsd_client.timing(self.metric_name, duration)

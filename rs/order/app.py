import os

import datetime

from flask import Flask, jsonify
import  prometheus_flask_exporter
from prometheus_flask_exporter.multiprocess import GunicornPrometheusMetrics
from requests import get

app = Flask(__name__)
metrics = GunicornPrometheusMetrics(app,defaults_prefix=prometheus_flask_exporter.NO_PREFIX)

@app.route('/')
def hello_world():
    return jsonify(message="Hello world order")


@app.route('/healthz')
@metrics.do_not_track()
def healthz():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


@app.route('/metrics')
@metrics.do_not_track()
def metrics():
    return get(f'http://localhost:8080/metrics').content


if __name__ == '__main__':
    metrics.start_http_server()
    app.run(debug=os.environ.get('DEBUG', False), host='0.0.0.0')

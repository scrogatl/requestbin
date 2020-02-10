#!/bin/ash
fluentd -vv -c fluent.conf &
newrelic-admin run-program gunicorn -b 0.0.0.0:8000 --worker-class gevent --workers 2 --max-requests 1000 requestbin:app

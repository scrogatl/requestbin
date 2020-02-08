FROM python:2.7-alpine

RUN apk update && apk upgrade && \
    apk add \
        gcc python python-dev py-pip \
        # greenlet
        musl-dev \
        # sys/queue.h
        bsd-compat-headers \
        # event.h
        libevent-dev \
                ruby \
        ruby-dev \
        make   \
    && rm -rf /var/cache/apk/*

RUN     gem install webrick
RUN     gem install json
RUN     gem install etc
RUN     gem install fluentd
RUN     fluent-gem install fluent-plugin-newrelic
ADD     fluent.conf /opt/requestbin/fluent.conf
    

# want all dependencies first so that if it's just a code change, don't have to
# rebuild as much of the container
ADD requirements.txt /opt/requestbin/
RUN pip install -r /opt/requestbin/requirements.txt \
    && rm -rf ~/.pip/cache

# the code
ADD requestbin  /opt/requestbin/requestbin/

EXPOSE 8000

#CMD gunicorn -b 0.0.0.0:8000 --worker-class gevent --workers 2 --max-requests 1000 requestbin:app
WORKDIR /opt/requestbin
CMD fluentd -c fluent.conf &
ENV NEW_RELIC_CONFIG_FILE=/opt/requestbin/requestbin/newrelic.ini
CMD newrelic-admin run-program gunicorn -b 0.0.0.0:8000 --worker-class gevent --workers 2 --max-requests 1000 requestbin:app

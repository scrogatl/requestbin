FROM debian:buster-slim

RUN apt update &&  \
    apt-get --assume-yes install \
        gcc python3  python3-pip\
        #bsd-compat-headers \
        libevent-dev \
        make

# want all dependencies first so that if it's just a code change, don't have to
# rebuild as much of the container
ADD requirements.txt /opt/requestbin/
RUN pip3 install -r /opt/requestbin/requirements.txt 
#    && rm -rf ~/.pip/cache

# the code
ADD requestbin  /opt/requestbin/requestbin/

EXPOSE 8000

WORKDIR /opt/requestbin
ENV NEW_RELIC_CONFIG_FILE=/opt/requestbin/requestbin/newrelic.ini
CMD newrelic-admin run-program gunicorn -b 0.0.0.0:8000 --worker-class gevent --workers 2 --max-requests 1000 requestbin:app

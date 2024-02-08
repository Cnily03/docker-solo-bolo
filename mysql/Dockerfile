FROM mysql:latest

COPY ./solo.init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/solo.init.sh

RUN sed -i '2i if [ -f /usr/local/bin/solo.init.sh ]; then solo.init.sh; fi;' /usr/local/bin/docker-entrypoint.sh


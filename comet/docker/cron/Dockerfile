FROM alpine:3.24.1

RUN apk add --no-cache docker-cli tzdata

COPY ./crontab /var/spool/cron/crontabs/root

ENTRYPOINT [ "crond", "-f" ]
CMD []


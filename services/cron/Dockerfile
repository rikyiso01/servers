FROM alpine:3.24.1

RUN apk add --no-cache docker-cli

COPY ./crontab /var/spool/cron/crontabs/crontab

ENTRYPOINT [ "crond", "-f" ]
CMD []


FROM alpine:latest

RUN apk add --no-cache bash socat jq curl

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]



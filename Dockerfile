FROM alpine:3.19

RUN apk add --no-cache git bash curl

COPY trigger-build.sh /trigger-build.sh
RUN chmod +x /trigger-build.sh

CMD ["/trigger-build.sh"]

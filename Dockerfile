FROM alpine
RUN apk add --no-cache \
    bash \
    httpie \
    jq && \
    which bash && \
    which http && \
    which jq
COPY entrypoint.sh /usr/local/bin/
COPY sampledata.json /sampledata.json
ENTRYPOINT [ "entrypoint.sh" ]

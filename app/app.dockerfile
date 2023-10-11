FROM alpine:latest

RUN mkdir /app

COPY App /app

CMD [ "/app/App"]
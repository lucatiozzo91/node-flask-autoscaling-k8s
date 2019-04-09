FROM golang:1.8

RUN mkdir /app

WORKDIR /app

ADD main.go /app

EXPOSE 8080

RUN go build -o main .
CMD ["/app/main"]
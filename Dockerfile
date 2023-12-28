FROM golang:1.20 as builder

WORKDIR /go/src/github.com/sebiuo/test-connectivity

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /go/bin/test-connectivity

FROM alpine:3.19

COPY --from=builder /go/bin/test-connectivity /test-connectivity

RUN addgroup -S go-app && adduser -S go-app -G go-app

RUN chown go-app:go-app /test-connectivity

USER go-app

ENTRYPOINT ["/test-connectivity"]

EXPOSE 8383

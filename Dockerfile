ARG HTTP_PROXY
FROM golang:alpine AS builder
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTP_PROXY
RUN echo $http_proxy
RUN apk update && apk add --no-cache git

RUN go get github.com/opsgang/prometheus_voltdb_exporter; exit 0
WORKDIR /go/src/github.com/opsgang/prometheus_voltdb_exporter
RUN sed -i 's/"regexp"/"regexp"\n\tejson "encoding\/json"/g' lib/collector.go
RUN sed -i 's/gjson.Unmarshal/ejson.Unmarshal/g' lib/collector.go

RUN go get github.com/prometheus/client_golang/prometheus
RUN go get github.com/tidwall/gjson

RUN env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a
RUN go install

FROM golang:alpine
COPY --from=builder /go/bin/prometheus_voltdb_exporter /prometheus_voltdb_exporter
EXPOSE 9469
ENTRYPOINT ["/prometheus_voltdb_exporter"]

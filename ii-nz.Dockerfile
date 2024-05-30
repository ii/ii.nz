FROM alpine:edge@sha256:f2d1645cd73c7e54584dc225da0b5229d19223412d719669ebda764f41396853 AS build
RUN apk add --no-cache 'hugo=0.125.4-r1'
COPY . /build
WORKDIR /build
RUN hugo
FROM registry.gitlab.com/bobymcbobs/go-http-server:1.10.0@sha256:fefe30ebfbf22ecf368da12760fd566857e827c5420026a5b060c444adf6e973 AS site
COPY --from=build /build/public /var/run/ko

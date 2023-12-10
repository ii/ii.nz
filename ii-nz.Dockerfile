FROM alpine:edge@sha256:f2d1645cd73c7e54584dc225da0b5229d19223412d719669ebda764f41396853 AS build
RUN apk add --no-cache 'hugo=0.120.4-r0'
COPY . /build
WORKDIR /build
RUN hugo
FROM registry.gitlab.com/bobymcbobs/go-http-server@sha256:6a15dd0b3054958ffa2c89e95a36eb3c009aeab25230227fd29399e87706c321 AS site
COPY --from=build /build/public /var/run/ko

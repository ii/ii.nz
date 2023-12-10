FROM alpine:3.18@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0 AS cfg
COPY cloudflared-config.yaml /etc/cloudflared/config.yaml
RUN chmod 0644 /etc/cloudflared/config.yaml && chown 65532:65532 /etc/cloudflared/config.yaml

FROM docker.io/cloudflare/cloudflared:2023.8.2@sha256:93561dfa0032006354be56476f09e3d8743d53d202368672c2847c1631f7be50 AS site
COPY --from=cfg /etc/cloudflared/config.yaml /etc/cloudflared/config.yaml

FROM alpine:3.18@sha256:34871e7290500828b39e22294660bee86d966bc0017544e848dd9a255cdf59e0 AS cfg
COPY cloudflared-config.yaml /etc/cloudflared/config.yaml
RUN chmod 0644 /etc/cloudflared/config.yaml

FROM docker.io/cloudflare/cloudflared:2023.10.0@sha256:c18744ae1767c17c5562cc731c24e64a5a2f93f35c3dd6629b90dedaff6dff8f
COPY --from=cfg /etc/cloudflared/config.yaml /usr/etc/cloudflared/config.yaml

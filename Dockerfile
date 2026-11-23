# LiveKit server, re-hosted onto the org's registry chain.
#
# LiveKit publishes a small (~60MB) multi-arch image; unlike mattermost there is
# no giant single layer to split. So this is the simple form: pin the upstream
# tag and copy its runtime files into a registry-reachable base. alpine is
# already present on every cluster node (pinned by node-image-keeper), so this
# adds no new pull dependency.
#
# Pin a specific version, never `latest` — the tag is the identity (see
# .github/workflows/image.yml, which reads it back out of this file).
FROM livekit/livekit-server:v1.13.11 AS upstream

FROM alpine:3.20

RUN apk add --no-cache ca-certificates
COPY --from=upstream /livekit-server /usr/local/bin/livekit-server

# LiveKit reads config from a file or flags; the deployment supplies
# /etc/livekit/livekit.yaml via a ConfigMap.
EXPOSE 7880 7881/udp 7881/tcp 7882/udp
ENTRYPOINT ["/usr/local/bin/livekit-server"]
CMD ["--config", "/etc/livekit/livekit.yaml"]

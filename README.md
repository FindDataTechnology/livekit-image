# LiveKit server image, re-hosted

Re-hosts LiveKit's upstream `livekit/livekit-server` onto
`ccr.ccs.tencentyun.com/fd-web/livekit-server`, because cluster nodes cannot pull
`docker.io` (measured: `ErrImagePull` on `livekit/livekit-server:v1.13.11`,
2026-11-24 — same wall mattermost-image and the scraw image hit before).

## Chain

```
GitHub Actions  ->  hkccr.ccs.tencentyun.com/fd-web/livekit-server
                ->  cheap9 relay (<=5 min)
                ->  ccr.ccs.tencentyun.com/fd-web/livekit-server  <- nodes pull here
```

## Why a dev machine cannot do it

A dev machine's registry credential is **read-only**: `skopeo copy` to any
hkccr/ccr repo (existing or new) fails with
`requested access to the resource is denied`. The write happens in this repo's
workflow, which uses the org's robot token (`secrets.TCR_USER`/`TCR_PASS`), the
same as every other org image.

## Upgrading

1. Change the pinned tag in `Dockerfile` (a **specific version**, never `latest`).
2. Push to `main` — the workflow builds, runs the binary on the new base to
   prove it links, then pushes.
3. Wait for the relay (<=5 min) to land it on ccr.
4. Verify **from a cluster node** (a green workflow is not evidence):
   ```
   k3s ctr -n k8s.io images pull ccr.ccs.tencentyun.com/fd-web/livekit-server:<tag>
   ```
5. Roll `fd-infra-deploy`'s livekit deployment to the new tag.

## Consumer

The AI-native meeting change (`openspec/changes/add-ai-native-meeting`) deploys
this as the media layer; see its design.md D1.

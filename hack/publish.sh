#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

cd "$(git rev-parse --show-toplevel)" || exit 0

LOCAL_REGISTRY="localhost:5001/$(pwd | md5sum | head -c6)"
BASE_IMAGE="$(< ./hack/image.yaml yq e .image -P)"
TAG="${TAG:-v$(git show -s --format=%cd --date=format:'%s')-$(git rev-parse HEAD | head -c8)}"
SIGN=false

# NOTE budget /bin/sh way
if echo "${@:-}" | grep -q '\-\-sign'; then
    SIGN=true
fi

cosign verify \
    --certificate-identity-regexp 'https://gitlab.com/BobyMCbobs/go-http-server//.gitlab-ci.yml@(refs/heads/main|refs/tags/.*)' \
    --certificate-oidc-issuer-regexp 'https://gitlab.com' \
    "$BASE_IMAGE" \
    -o text

rm -rf public output
hugo

# bit of a hack
# perhaps there's a way to say
# to tar to pack dir into a new dir?
mkdir -p output/var/run
mv public output/var/run/ko
chmod -R 0755 output/

IMAGE_ARM64="$(crane append --platform=linux/arm64 \
    --base="$BASE_IMAGE" \
    --new_layer=<(cd output && tar --exclude=".DS_Store" -f - -c .) \
    --new_tag="${CONTAINER_REPO:-$LOCAL_REGISTRY}")"
IMAGE_AMD64="$(crane append --platform=linux/amd64 \
    --base="$BASE_IMAGE" \
    --new_layer=<(cd output && tar --exclude=".DS_Store" -f - -c .) \
    --new_tag="${CONTAINER_REPO:-$LOCAL_REGISTRY}")"
IMAGE="$(crane index append \
    -m "${IMAGE_ARM64}" \
    -m "${IMAGE_AMD64}" \
    -t "${CONTAINER_REPO:-$LOCAL_REGISTRY}:$TAG")"

if [ "$SIGN" = true ]; then
    cosign sign -y --recursive "$IMAGE"
fi

echo "Published image to: $IMAGE"

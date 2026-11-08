# Build native assets once; cross-compile only the Go server.
FROM --platform=$BUILDPLATFORM node:22-bookworm-slim AS assets
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

FROM --platform=$BUILDPLATFORM golang:1.27 AS server
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
    -ldflags='-w -s -X google.golang.org/protobuf/reflect/protoregistry.conflictPolicy=ignore' \
    -o /out/web-ui .

# Retain the official downloader, transcoder, database, init and storage services.
FROM ghcr.io/webtor-io/self-hosted:latest
LABEL org.opencontainers.image.source="https://github.com/YuanBaian/web-ui"
LABEL org.opencontainers.image.description="Webtor NAS all-in-one with Simplified Chinese UI"
COPY --from=server /out/web-ui /app/web-ui/web-ui
COPY --from=server /src/templates /app/web-ui/templates
COPY --from=server /src/migrations /app/web-ui/migrations
COPY --from=server /src/pub /app/web-ui/pub
# Remove old hashed bundles so upgrades do not retain conflicting manifests.
RUN rm -rf /app/web-ui/assets/dist
COPY --from=assets /src/assets/dist /app/web-ui/assets/dist

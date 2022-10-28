FROM rust:1.64.0-alpine AS builder

ARG VERSION
ARG COMMIT_HASH

RUN apk add --update musl-dev

WORKDIR /home/src

COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock
COPY src/main.rs src/main.rs
RUN cargo fetch --locked --target x86_64-unknown-linux-musl

COPY . .
RUN cargo build --release --locked --target x86_64-unknown-linux-musl


FROM alpine:latest AS cli

ARG REPO_URL
ARG DESCRIPTION
LABEL org.opencontainers.image.source ${REPO_URL}
LABEL org.opencontainers.image.description ${DESCRIPTION}

WORKDIR /root/

COPY --from=builder /home/src/target/x86_64-unknown-linux-musl/release/git-conventional-commits .

ENTRYPOINT ["./git-conventional-commits"]

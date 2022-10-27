FROM rust:1.64.0-alpine AS builder

RUN apk add --update make musl-dev

WORKDIR /home/src

COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock
COPY src/main.rs src/main.rs
RUN cargo fetch --locked --target x86_64-unknown-linux-musl

COPY . .
RUN cargo build --release --locked --target x86_64-unknown-linux-musl


FROM alpine:latest AS cli

ARG GITHUB_PATH=github.com/arttet/git-conventional-commits
LABEL org.opencontainers.image.source https://${GITHUB_PATH}

WORKDIR /root/

COPY --from=builder /home/src/target/x86_64-unknown-linux-musl/release/git-conventional-commits .

ENTRYPOINT ["./git-conventional-commits"]

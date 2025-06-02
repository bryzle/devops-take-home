# --- Build stage ---
FROM rustlang/rust:nightly AS builder

WORKDIR /app
COPY . .

# Add Linux target + build for it
RUN rustup target add x86_64-unknown-linux-gnu
RUN cargo build --release --target x86_64-unknown-linux-gnu

# --- Runtime stage ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the Linux binary
COPY --from=builder /app/target/x86_64-unknown-linux-gnu/release/devops-takehome .

EXPOSE 8080
CMD ["./devops-takehome"]

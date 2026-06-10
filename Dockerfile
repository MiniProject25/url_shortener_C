# ==============================================================================
# Stage 1: Build the C application
# ==============================================================================
FROM alpine:latest AS builder

# Install compilers and database dependencies needed for compilation
RUN apk add --no-cache \
    gcc \
    musl-dev \
    sqlite-dev

# Set the build working directory
WORKDIR /build

# Copy the source files
COPY . .

# Compile the application with optimizations (-O2) and link SQLite (-lsqlite3)
RUN gcc -O2 *.c -lsqlite3 -o http_server

# ==============================================================================
# Stage 2: Create a minimal deployment image
# ==============================================================================
FROM alpine:latest

# Install only the runtime dependency for SQLite
RUN apk add --no-cache sqlite-libs

# Set application directory
WORKDIR /app

# Copy the compiled executable from the build stage
COPY --from=builder /build/http_server /app/http_server

# Expose the port the server listens on
EXPOSE 8000

# Start the application
CMD ["./http_server"]

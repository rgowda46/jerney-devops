# -------------------------------------------------------
# Stage 1: Install application dependencies
# -------------------------------------------------------
# Uses a lightweight Alpine Linux image with Node.js 20
# This stage only installs dependencies and will not be
# included in the final image.
FROM node:20-alpine AS dependencies

# Set working directory inside container
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install only production dependencies
# Excludes devDependencies to keep image smaller
RUN npm ci --omit=dev


# -------------------------------------------------------
# Stage 2: Production Runtime Image
# -------------------------------------------------------
# Start with a fresh Node.js Alpine image
# Final image contains only what is needed to run the app
FROM node:20-alpine

# Install dumb-init
# Helps handle signals correctly inside containers
# Prevents zombie processes and PID 1 issues
RUN apk add --no-cache dumb-init

# Set working directory
WORKDIR /app

# Copy production node_modules from previous stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy application source code
COPY . .

# Create a non-root user and group
# Running containers as root is not recommended
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Application listens on port 5000
EXPOSE 5000

# Use dumb-init as PID 1
# Ensures proper signal handling during stop/restart
ENTRYPOINT ["dumb-init", "--"]

# Start Node.js application
CMD ["node", "src/index.js"]

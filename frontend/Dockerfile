# -------------------------------------------------------
# Stage 1: Build React Application
# -------------------------------------------------------
# Uses Node.js to install dependencies and generate
# optimized production build files.
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files first for layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci && npm cache clean --force

# Copy application source code
COPY . .

# Generate production build
RUN npm run build


# -------------------------------------------------------
# Stage 2: Nginx Runtime Image
# -------------------------------------------------------
# Uses lightweight Nginx image to serve static React files.
FROM nginx:1.27-alpine AS production

# Remove default nginx configuration and default web content
RUN rm -rf /etc/nginx/conf.d/default.conf \
           /usr/share/nginx/html/*

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy React build artifacts from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Create required directories and assign permissions
# to nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

# Run container as non-root user
USER nginx

# Application exposed through Nginx
EXPOSE 80

# Keep Nginx running in foreground
CMD ["nginx", "-g", "daemon off;"]

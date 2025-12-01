# Multi-stage Dockerfile for backend
# Builder: install deps and compile TypeScript
FROM node:18-alpine AS builder
WORKDIR /app

# Install build dependencies
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps

# Copy source and build
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# Production image: install only production deps and copy compiled output
FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Install production dependencies
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps --omit=dev

# Copy built files from builder
COPY --from=builder /app/dist ./dist

EXPOSE 3847

CMD ["node","dist/index.js"]

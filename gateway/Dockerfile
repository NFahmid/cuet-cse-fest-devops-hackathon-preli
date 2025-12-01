FROM node:18-alpine
WORKDIR /app

# Use production environment
ENV NODE_ENV=production

# Install production dependencies
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps --omit=dev \
	&& npm cache clean --force

# Copy source
COPY src ./src

# Gateway listens on 5921 per project requirements
EXPOSE 5921

# Drop privileges and run as non-root user
USER node

CMD ["node", "src/gateway.js"]

# =============================================================================
# Dockerfile para API da Nuvem (Node.js)
# =============================================================================

FROM node:18-alpine AS base

# Instalação de dependências do sistema
RUN apk add --no-cache \
    python3 \
    make \
    g++

WORKDIR /app

# =============================================================================
# Stage: Development
# =============================================================================
FROM base AS development

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN npm install

# Copiar código fonte
COPY . .

# Expor porta
EXPOSE 3000

# Comando para desenvolvimento (com hot reload)
CMD ["npm", "run", "dev"]

# =============================================================================
# Stage: Production
# =============================================================================
FROM base AS production

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar apenas dependências de produção
RUN npm ci --only=production

# Copiar código fonte
COPY . .

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Mudar ownership dos arquivos
RUN chown -R nodejs:nodejs /app

# Mudar para usuário não-root
USER nodejs

# Expor porta
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Comando para produção
CMD ["node", "src/index.js"]
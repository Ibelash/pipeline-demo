FROM node:18-slim

WORKDIR /app
COPY app/package.json ./
COPY app/index.js ./

RUN npm install --omit=dev

# ⚠️ Falta intencional: no se define USER, así que el contenedor corre como root.
# Trivy / un reviewer de Dockerfile debería marcar esto (CIS Docker Benchmark 4.1).
# Corrección real: crear un usuario sin privilegios y usar "USER appuser" aquí.

EXPOSE 3000
CMD ["node", "index.js"]

# Pipeline de práctica - Application Security Specialist

Mini-repo para mostrar hallazgos **reales**

## Qué hay aquí

```
app/                          → app Express con una dependencia vulnerable a propósito (lodash 4.17.4)
                                 y dos "secretos" de ejemplo en index.js
terraform/main.tf             → infraestructura con fallas de config a propósito
Dockerfile                    → imagen que corre como root a propósito
.github/workflows/
  security-pipeline.yml       → el pipeline completo: secrets → SAST → SCA →
                                 IaC → build+container scan → SBOM → DAST
evidence/                     → salidas REALES de correr las herramientas contra este repo
  npm-audit-output.txt        → 8 vulnerabilidades reales (1 crítica, 4 altas)
  checkov-output.txt          → 21 checks fallidos reales sobre terraform/main.tf
  gitleaks-report.json        → 1 secreto sintético detectado (stripe-access-token)
  gitleaks-console.txt        → salida de consola de gitleaks
```

## Los 3 hallazgos reales, explicados

### 1. SCA — `npm audit` (evidence/npm-audit-output.txt)
`lodash@4.17.4` trae **1 vulnerabilidad crítica** (prototype pollution,
GHSA-fvqr-27wr-82fm) y varias altas en `express`/`body-parser`/`qs` por
dependencias transitivas desactualizadas. 8 vulnerabilidades en total con
CVEs/advisories reales de GitHub.

**Para la entrevista:** esto es exactamente el caso de "SAST/SCA con 200
findings" — aquí no son 200, pero la lógica es la misma: la vulnerabilidad
crítica de lodash bloquearía el merge (`npm audit --audit-level=high` sale
con exit code ≠ 0), las de severidad media/baja quedarían visibles sin
bloquear.

### 2. IaC scanning — Checkov (evidence/checkov-output.txt)
**21 checks fallidos** sobre 3 recursos de Terraform: bucket S3 público y
sin encriptar, security group con SSH abierto a `0.0.0.0/0`, y una policy
IAM con `Action: "*"` / `Resource: "*"`.

**Para la entrevista:** la política IAM con `*:*` es el ejemplo perfecto de
"por qué el orden importa" — Checkov lo marca en el build, antes de que
`terraform apply` cree ese rol en una cuenta real.

### 3. Secrets scanning — gitleaks (evidence/gitleaks-report.json)
Aquí pasó algo genuinamente interesante y vale la pena contarlo en la
entrevista tal como ocurrió:

- La primera clave de ejemplo que puse (`AKIAIOSFODNN7EXAMPLE`, la que AWS
  usa en su propia documentación pública) **no fue detectada**. gitleaks la
  trae en su allowlist por defecto, precisamente porque es tan conocida que
  generaría ruido constante en miles de repos que la citan como ejemplo.
- Agregué una segunda clave sintética (formato `sk_live_...`, sin significado
  real) y esa **sí fue detectada** — regla `stripe-access-token`, con el
  commit, archivo y línea exactos.

**Para la entrevista:** esto es una demostración real de "cómo manejo falsos
positivos/negativos sin perder cobertura" — un allowlist mal pensado puede
ocultar hallazgos reales si alguien reutiliza un patrón "de ejemplo" con
datos reales. Es un buen contraejemplo para hablar de por qué las
supresiones necesitan revisión periódica.

## Cómo reproducirlo

```bash
# SCA
cd app && npm install --package-lock-only && npm audit

# IaC scanning
pip install checkov
checkov -d terraform/ --compact

# Secrets scanning
gitleaks detect --source . --verbose
```

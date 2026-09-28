const express = require("express");
const _ = require("lodash");

const app = express();

// ⚠️ EJEMPLO INTENCIONAL para el demo de secrets scanning.
// Esta es la access key de ejemplo que AWS usa en su propia documentación pública
// (https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html),
// no es una credencial real. El objetivo es que gitleaks/trufflehog la detecten
// por el patrón AKIA[0-9A-Z]{16}, igual que detectarían una credencial real.
const AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE";
const AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";

// ⚠️ Segundo secreto de ejemplo: este SÍ es una cadena sintética sin ningún
// significado real, generada solo para esta demo — no aparece en ninguna
// documentación pública, así que gitleaks no debería tenerla en su allowlist
// y debería detectarla por patrón de nombre de variable + entropía.
const PAYMENT_GATEWAY_API_KEY = "sk_live_51N7qK2mR9tXvB4pL8wY3cJ6fH0dQaZeT";

app.get("/status", (req, res) => {
  const payload = _.merge({}, { status: "ok", ts: Date.now() });
  res.json(payload);
});

app.listen(3000, () => console.log("demo-app escuchando en :3000"));

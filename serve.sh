#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  CrediHipo — servidor local para habilitar datos en vivo
#  Uso: chmod +x serve.sh && ./serve.sh
# ─────────────────────────────────────────────────────────────

PORT=8080
DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "🏠  CrediHipo — servidor local"
echo "────────────────────────────────"

# Verificar que Python 3 esté disponible
if command -v python3 &>/dev/null; then
  echo "✓  Python $(python3 --version | cut -d' ' -f2) detectado"
  echo "→  Abrí en tu navegador: http://localhost:$PORT"
  echo "→  Ctrl+C para detener"
  echo ""
  cd "$DIR"
  python3 -m http.server $PORT
elif command -v python &>/dev/null; then
  echo "✓  Python $(python --version 2>&1 | cut -d' ' -f2) detectado"
  echo "→  Abrí en tu navegador: http://localhost:$PORT"
  echo "→  Ctrl+C para detener"
  echo ""
  cd "$DIR"
  python -m SimpleHTTPServer $PORT
elif command -v npx &>/dev/null; then
  echo "✓  Node.js / npx detectado"
  echo "→  Abrí en tu navegador: http://localhost:3000"
  echo "→  Ctrl+C para detener"
  echo ""
  cd "$DIR"
  npx serve .
else
  echo "✗  No se encontró Python 3, Python 2 ni npx."
  echo ""
  echo "Opciones:"
  echo "  • Instalar Python: https://python.org"
  echo "  • Instalar Node.js: https://nodejs.org"
  echo "  • O usar la extensión 'Live Server' en VS Code"
  exit 1
fi

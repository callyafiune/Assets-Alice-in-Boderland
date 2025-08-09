#!/usr/bin/env bash
# Uso: ./merge_assets.sh prompt.txt assets.txt saida.txt "[ASSETS]"
set -euo pipefail

PROMPT_FILE="${1:?Informe o prompt.txt}"
ASSETS_FILE="${2:?Informe o assets.txt}"
OUT_FILE="${3:?Informe o arquivo de saída}"
TOKEN="${4:-[ASSETS]}"

if ! grep -qF "$TOKEN" "$PROMPT_FILE"; then
  echo "Erro: token '$TOKEN' não encontrado em $PROMPT_FILE" >&2
  exit 1
fi

# Escapa barras para o sed
ESCAPED_TOKEN=$(printf '%s\n' "$TOKEN" | sed -e 's/[\/&]/\\&/g')

# Gera bloco de assets
ASSETS_BLOCK=$(cat "$ASSETS_FILE")

# Cria arquivo temporário com o bloco seguro para sed
TMP_ASSETS="$(mktemp)"
printf '%s\n' "$ASSETS_BLOCK" > "$TMP_ASSETS"

# Substitui o token pelo conteúdo do arquivo (sed com leitura do tmp)
# macOS usa 'sed -i ''' e Linux 'sed -i'. Usamos uma saída intermediária para ser portátil.
sed "s/$ESCAPED_TOKEN/###ASSETS_PLACEHOLDER###/g" "$PROMPT_FILE" > "$OUT_FILE"
awk -v RS='###ASSETS_PLACEHOLDER###' -v ORS="" 'NR==1{print} NR>1{system("cat '"$TMP_ASSETS"'")}' "$OUT_FILE" > "$OUT_FILE.tmp"
mv "$OUT_FILE.tmp" "$OUT_FILE"
rm -f "$TMP_ASSETS"

echo "OK! Arquivo mesclado em: $OUT_FILE"

#!/bin/bash

# ───────── CONFIGURAÇÕES ─────────
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TMP_JSON="resultado.json"
LINHA="──────────────────────────────────────────────"

# ───────── CABEÇALHO ─────────
clear
echo -e "\e[1;36m$LINHA"
echo -e "\e[1;32m        EG WEBCODE - CONSULTAR NOME"
echo -e "\e[1;36m$LINHA\e[0m"

# ───────── INPUT ─────────
echo -ne "\n\e[1;33mDigite o nome no formato: nome+sobrenome+...\e[0m\n> "
read NOME
NOME=$(echo "$NOME" | tr '[:upper:]' '[:lower:]')

# ───────── LAÇO DE PAGINAÇÃO ─────────
PAGINA=1
TOTAL_ENCONTRADOS=0

while true; do
  echo -e "\n\e[1;34m[*] Consultando página $PAGINA...\e[0m"

  API_URL="https://sua.api.aqui/endpoint?nome=$NOME&pagina=$PAGINA"
  curl -s -A "$USER_AGENT" "$API_URL" -o "$TMP_JSON"

  TOTAL=$(jq '.registros | length' "$TMP_JSON")

  if [[ "$TOTAL" -eq 0 ]]; then
    if [[ "$PAGINA" -eq 1 ]]; then
      echo -e "\e[1;31m[-] Nenhum resultado encontrado.\e[0m"
    else
      echo -e "\n\e[1;32m[✓] Fim da listagem. Total exibido: $TOTAL_ENCONTRADOS\e[0m"
    fi
    break
  fi

  jq -c '.registros[]' "$TMP_JSON" | while read -r item; do
    NOME_COMPLETO=$(echo "$item" | jq -r '.nome')
    CPF_NIS=$(echo "$item" | jq -r '.cpfNis')
    RELACAO=$(echo "$item" | jq -r '.descricaoRelacoesGovernoFederal')

    echo -e "\e[1;36m$LINHA"
    echo -e "\e[1;37mNOME     :\e[0m $NOME_COMPLETO"
    echo -e "\e[1;37mCPF/NIS  :\e[0m $CPF_NIS"
    echo -e "\e[1;37mRELAÇÃO  :\e[0m $RELACAO"

    ((TOTAL_ENCONTRADOS++))
  done

  ((PAGINA++))
done

echo -e "\e[1;36m$LINHA\e[0m"

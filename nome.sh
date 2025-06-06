#!/bin/bash

# ───────── CONFIGURAÇÕES ─────────
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TMP_JSON="resultado.json"
LINHA="──────────────────────────────────────────────"

# ───────── CABEÇALHO BONITO COM SEU NOME ─────────
clear
echo -e "\e[1;36m$LINHA"
echo -e "\e[1;32m        EG WEBCODE - CONSULTAR NOME"
echo -e "\e[1;36m$LINHA\e[0m"

# ───────── INPUT DO USUÁRIO ─────────
echo -ne "\n\e[1;33mDigite o nome no formato: nome+sobrenome+...\e[0m\n> "
read NOME

# ───────── FORÇA minúsculas ─────────
NOME=$(echo "$NOME" | tr '[:upper:]' '[:lower:]')

# ───────── SUA URL DA API AQUI ─────────
API_URL="https://sua.api.aqui/endpoint?nome=$NOME"

echo -e "\n\e[1;34m[*] Consultando a API...\e[0m"
curl -s -A "$USER_AGENT" "$API_URL" -o "$TMP_JSON"

# ───────── VERIFICA ERROS ─────────
if [[ ! -s "$TMP_JSON" ]]; then
  echo -e "\e[1;31m[!] Nenhuma resposta recebida da API.\e[0m"
  exit 1
fi

# ───────── VERIFICA SE HÁ REGISTROS ─────────
TOTAL=$(jq -r '.totalRegistros' "$TMP_JSON")
if [[ "$TOTAL" -eq 0 ]]; then
  echo -e "\e[1;31m[-] Nenhum resultado encontrado.\e[0m"
  exit 1
fi

echo -e "\n\e[1;32m[+] $TOTAL resultado(s) encontrado(s):\e[0m"

# ───────── EXIBE DADOS ─────────
jq -c '.registros[]' "$TMP_JSON" | while read -r item; do
  NOME_COMPLETO=$(echo "$item" | jq -r '.nome')
  CPF_NIS=$(echo "$item" | jq -r '.cpfNis')
  RELACAO=$(echo "$item" | jq -r '.descricaoRelacoesGovernoFederal')

  echo -e "\e[1;36m$LINHA"
  echo -e "\e[1;37mNOME     :\e[0m $NOME_COMPLETO"
  echo -e "\e[1;37mCPF/NIS  :\e[0m $CPF_NIS"
  echo -e "\e[1;37mRELAÇÃO  :\e[0m $RELACAO"
done

echo -e "\e[1;36m$LINHA\e[0m"

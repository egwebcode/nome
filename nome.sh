#!/bin/bash

# ───────── CONFIGURAÇÕES ─────────
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TMP_JSON="resultado.json"
LINHA="──────────────────────────────────────────────"

# ───────── INTERFACE ─────────
clear
echo -e "\e[1;36m$LINHA"
echo -e "     CONSULTA - PORTAL TRANSPARÊNCIA (API)"
echo -e "$LINHA\e[0m"
echo -ne "\n\e[1;33mDigite o nome no formato: Jnome+sobrenome+...\e[0m\n> "
read NOME

# ───────── VALIDA FORMATO ─────────
if [[ ! "$NOME" =~ ^J.+ ]]; then
  echo -e "\e[1;31m[!] O nome deve começar com 'J'. Tente novamente.\e[0m"
  exit 1
fi

# ───────── URL DA API (INSIRA SUA AQUI) ─────────
# Exemplo de URL: https://api.portaldatransparencia.gov.br/pessoa-fisica?nome=$NOME&token=SEU_TOKEN
API_URL="https://sua.api.aqui/endpoint?nome=$NOME"

echo -e "\n\e[1;34m[*] Consultando a API...\e[0m"
curl -s -A "$USER_AGENT" "$API_URL" -o "$TMP_JSON"

# ───────── VERIFICA ERROS ─────────
if [[ ! -s "$TMP_JSON" ]]; then
  echo -e "\e[1;31m[!] Nenhuma resposta recebida da API.\e[0m"
  exit 1
fi

if jq -e '.erro' "$TMP_JSON" &>/dev/null; then
  ERRO=$(jq -r '.erro' "$TMP_JSON")
  echo -e "\e[1;31m[!] Erro da API: $ERRO\e[0m"
  exit 1
fi

# ───────── EXIBE DADOS ─────────
RESULTADOS=$(jq '. | length' "$TMP_JSON")
if [[ "$RESULTADOS" -eq 0 ]]; then
  echo -e "\e[1;31m[-] Nenhum resultado encontrado.\e[0m"
  exit 1
fi

echo -e "\n\e[1;32m[+] Resultados encontrados:\e[0m"

jq -c '.[]' "$TMP_JSON" | while read -r item; do
  NOME_COMPLETO=$(echo "$item" | jq -r '.nome')
  CPF=$(echo "$item" | jq -r '.cpf // "NÃO INFORMADO"')
  ORGAO=$(echo "$item" | jq -r '.orgao // "NÃO INFORMADO"')
  CARGO=$(echo "$item" | jq -r '.cargo // "NÃO INFORMADO"')

  echo -e "\e[1;36m$LINHA"
  echo -e "\e[1;37mNOME :\e[0m $NOME_COMPLETO"
  echo -e "\e[1;37mCPF  :\e[0m $CPF"
  echo -e "\e[1;37mÓRGÃO:\e[0m $ORGAO"
  echo -e "\e[1;37mCARGO:\e[0m $CARGO"
done

echo -e "\e[1;36m$LINHA\e[0m"

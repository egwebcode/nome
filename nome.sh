#!/bin/bash

# ───────── CONFIGURAÇÕES ─────────
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
TMP_FILE="resultado.html"
LINHA="──────────────────────────────────────────────"

# ───────── INTERFACE INTERATIVA ─────────
clear
echo -e "\e[1;36m$LINHA"
echo -e "     CONSULTA - PORTAL DA TRANSPARÊNCIA"
echo -e "$LINHA\e[0m"
echo -ne "\n\e[1;33mDigite o nome no formato: NOME+SOBRENOME+...\e[0m\n> "
read NOME

# ───────── REQUISIÇÃO ─────────
URL="https://portaldatransparencia.gov.br/pessoa-fisica/busca/resultado?termo=$NOME&pagina=1&tamanhoPagina=10"
echo -e "\n\e[1;34m[*] Consultando...\e[0m"
curl -s -A "$USER_AGENT" "$URL" -o "$TMP_FILE"

# ───────── VERIFICA BLOQUEIO OU ERRO ─────────
if grep -q "recaptcha" "$TMP_FILE"; then
  echo -e "\e[1;31m[!] Bloqueado por reCAPTCHA. Tente novamente mais tarde.\e[0m"
  exit 1
fi

# ───────── VERIFICA RESULTADOS ─────────
if ! grep -q "/pessoa-fisica/" "$TMP_FILE"; then
  echo -e "\e[1;31m[-] Nenhum resultado encontrado.\e[0m"
  exit 1
fi

# ───────── EXTRAI E EXIBE DADOS ─────────
echo -e "\n\e[1;32m[+] Resultados encontrados:\e[0m"

# Extrai blocos de resultado
grep -oP '(?s)<div class="col-md-12 resultado-pesquisa.*?</div>\s*</div>' "$TMP_FILE" | while read -r bloco; do
  NOME_COMPLETO=$(echo "$bloco" | grep -oP '(?<=<a href="/pessoa-fisica/)[^"]+' | cut -d/ -f2 | sed 's/-/ /g' | tr '[:lower:]' '[:upper:]')
  CPF=$(echo "$bloco" | grep -oP '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}' | head -1)
  ORGAO=$(echo "$bloco" | grep -oP '(?<=Órgão: </strong>).*?(?=<)' | head -1)
  CARGO=$(echo "$bloco" | grep -oP '(?<=Cargo: </strong>).*?(?=<)' | head -1)

  echo -e "\e[1;36m$LINHA"
  echo -e "\e[1;37mNOME :\e[0m $NOME_COMPLETO"
  echo -e "\e[1;37mCPF  :\e[0m $CPF"
  echo -e "\e[1;37mÓRGÃO:\e[0m $ORGAO"
  echo -e "\e[1;37mCARGO:\e[0m $CARGO"
done

echo -e "\e[1;36m$LINHA\e[0m"

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
URL="https://portaldatransparencia.gov.br/pessoa-fisica/busca/resultado?termo=$NOME&pagina=1&tamanhoPagina=10&t=wdUJNlyLKulB1HjVJkn0&tokenRecaptcha=03AFcWeA4DXPwC9M1vCB5CO9KM1PqzNxwp2gNs80thmXkCJLg9w9PzDwxJv14wggAUnNAWamNIMRKxSq3a5_mRzciHUo1Lq5_-ICGBofvCfeHEhQOxJwP5e-ys9FXEmiJk9jF4LIGilEujQga0SDwN-WU7IJ0aWlKB32SAxceX9iz9kS49_ZhSC2oFaWv9CTTr9JaobNyNczk3gs-gOTfCtJf1wF-j69zM5AMfAwbPorXoYETIZ7sG8qYtcIemdPKvPJc78HqbM3DS4HUm3GhqM6ZNGqY5e8kW8-U3_rGUXBI3CfXrb9IKOS-vBI2J-xvQpz3KhNWJ3k2v2-9sP0MJJ3nqkgIoB5JQS14EK1plXeaQF2Ez2YFXH03ZfUbVF4-253NAon3xsAr_8lfaM-APpuabMFJ3cF1LihK3lEo9ebkrCs7du8M95XNhwqtRCJ9AueyUTAxvKmBMsM6cs8vMap7BQvPUkPyDqc-s6bOjfp8z11ahS_sVqZ9XLMEHdJriC-eGP3rXc5wrYOU3H9dG6xS8ykm1YCBxp4tJ85vyVWqXBmxo620uIhZea_6fc11FRXkXxfwKZzVMl5P-OQvqaqjHX94k486jeHP910SAbNIkeKqEqN3SCIj-XPkHLqh0-nkdr5Hl1sYi_xNzCfCJEiNTwtjwIjQ8vTidojbIfLHbRI3jzEYLS7XZIJusJClYJm1zZnT5ePRZn14Grse2aIzGzZoyM0ANOQbtV3WZm538bGkrUl5NFWYw4pF5yYx0jf-8fHzwMQgsAMMdQcuS2SdUXOtsOQOLae71Jlxe945kxllejVW-hoi0_dsd_ebKzSD84vTIpCRRwt5Qrn-8aJXwMFZOg9Z-ToGnWlFPSo0Cpp7N613aKK2K8ozdNH5SF3MpvZM7aj-bGU2mMGrWjmjo85OaNXF04RCGqmLS58r5JNx3mp6crhzZbqcbh0qntEanK6ATdyug"
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

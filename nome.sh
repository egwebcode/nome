#!/bin/bash

# ───────── CONFIGURAÇÕES ─────────
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64)"
TMP_FILE="resultado.html"
RESULT_FILE="resultados.txt"
LINHA="──────────────────────────────────────────────"

# Limpa resultado anterior
> "$RESULT_FILE"

# ───────── CABEÇALHO ─────────
clear
echo -e "\e[1;36m$LINHA"
echo -e "\e[1;32m        EG WEBCODE - CONSULTAR NOME"
echo -e "\e[1;36m$LINHA\e[0m"

# ───────── INPUT ─────────
echo -ne "\n\e[1;33mDigite o nome no formato: nome+sobrenome+...\e[0m\n> "
read NOME
NOME=$(echo "$NOME" | tr '[:upper:]' '[:lower:]')

# ───────── VARIÁVEL DE CONTAGEM ─────────
COUNT=0
CPF_REGISTRADOS=()

# ───────── LAÇO DE PÁGINAS ─────────
for PAGINA in $(seq 1 100); do
  echo -e "\n\e[1;34m[*] Consultando página $PAGINA...\e[0m"

  URL="https://portaldatransparencia.gov.br/pessoa-fisica/busca/resultado?termo=$NOME&pagina=$PAGINA&tamanhoPagina=10&t=wdUJNlyLKulB1HjVJkn0&tokenRecaptcha="

  curl -s -A "$USER_AGENT" "$URL" -o "$TMP_FILE"

  # Verifica bloqueio do reCAPTCHA
  if grep -q "recaptcha" "$TMP_FILE"; then
    echo -e "\e[1;31m[!] Bloqueado por reCAPTCHA. Tente novamente mais tarde.\e[0m"
    break
  fi

  # Captura os blocos de pessoas
  BLOCOS=$(grep -oP '(?s)<div class="col-md-12 resultado-pesquisa.*?</div>\s*</div>' "$TMP_FILE")

  # Se não houver blocos, encerra
  if [[ -z "$BLOCOS" ]]; then
    echo -e "\e[1;33m[!] Nenhum resultado encontrado na página $PAGINA. Encerrando...\e[0m"
    break
  fi

  # Processa cada bloco
  echo "$BLOCOS" | while read -r bloco; do
    NOME_COMPLETO=$(echo "$bloco" | grep -oP '(?<=<a href="/pessoa-fisica/)[^"]+' | cut -d/ -f2 | sed 's/-/ /g' | tr '[:lower:]' '[:upper:]')
    CPF=$(echo "$bloco" | grep -oP '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}' | head -1)
    ORGAO=$(echo "$bloco" | grep -oP '(?<=Órgão: </strong>).*?(?=<)' | head -1)
    CARGO=$(echo "$bloco" | grep -oP '(?<=Cargo: </strong>).*?(?=<)' | head -1)

    # Evita duplicados com base no CPF
    if [[ " ${CPF_REGISTRADOS[*]} " =~ " $CPF " ]]; then
      continue
    fi
    CPF_REGISTRADOS+=("$CPF")
    ((COUNT++))

    # Exibe no terminal
    echo -e "\e[1;36m$LINHA"
    echo -e "\e[1;37mPESSOA ($COUNT)"
    echo -e "NOME : $NOME_COMPLETO"
    echo -e "CPF  : $CPF"
    echo -e "ÓRGÃO: $ORGAO"
    echo -e "CARGO: $CARGO"

    # Salva no .txt
    {
      echo "$LINHA"
      echo "PESSOA ($COUNT)"
      echo "NOME : $NOME_COMPLETO"
      echo "CPF  : $CPF"
      echo "ÓRGÃO: $ORGAO"
      echo "CARGO: $CARGO"
    } >> "$RESULT_FILE"
  done
done

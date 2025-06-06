#!/bin/bash

# Verifica se o nome foi fornecido como argumento
if [ -z "$1" ]; then
  echo "Uso: $0 \"NOME COMPLETO\""
  exit 1
fi

# Converte o nome para URL encode (substitui espaços por +)
NOME=$(echo "$1" | sed 's/ /+/g')

# URL base da pesquisa (sem o tokenRecaptcha)
URL="https://portaldatransparencia.gov.br/pessoa-fisica/busca/resultado?termo=$NOME&pagina=1&tamanhoPagina=10"

# Cabeçalhos para simular um navegador real
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"

# Executa a requisição
echo "[*] Consultando nome: $1"
curl -s -A "$USER_AGENT" "$URL" -o resultado.html

# Verifica se a consulta retornou algo
if grep -q "pessoa-fisica/" resultado.html; then
  echo "[+] Resultado salvo em resultado.html"
else
  echo "[-] Nenhum resultado encontrado ou bloqueado pelo site (recaptcha?)"
fi

#!/usr/bin/env bash

set -euo pipefail

# Quarto 1.6.40 apresenta conflito ao renderizar vários documentos
# multi-formato em paralelo. Primeiro montamos o site em HTML e depois
# renderizamos cada capítulo, sequencialmente, nos formatos declarados.
quarto render --to html

for source in capitulos/*.qmd; do
  quarto render "$source" --quiet
done

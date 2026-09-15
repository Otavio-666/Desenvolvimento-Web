#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob nocaseglob

# Uso:
#   ./ordernar.bash        -> prévia
#   ./ordernar.bash --run  -> executa

RUN=false
[[ "${1:-}" == "--run" ]] && RUN=true

SCRIPT="$(basename -- "$0")"
BACKUP_DIR="backup_originais_$(date +%Y%m%d_%H%M%S)"
TMP_DIR=".tmp_jpeg_$$"

# Escolhe conversor disponível
if command -v magick >/dev/null 2>&1; then
    CONVERTER="magick"
elif command -v convert >/dev/null 2>&1; then
    CONVERTER="convert"
elif command -v ffmpeg >/dev/null 2>&1; then
    CONVERTER="ffmpeg"
else
    echo "ERRO: nenhum conversor encontrado."
    echo "Instale um deles:"
    echo "  sudo apt update && sudo apt install imagemagick"
    echo "ou:"
    echo "  sudo apt update && sudo apt install ffmpeg"
    exit 1
fi

arquivos=()

for arquivo in *; do
    [[ -f "$arquivo" ]] || continue
    [[ "$arquivo" == "$SCRIPT" ]] && continue

    case "${arquivo,,}" in
        *.jpg|*.jpeg|*.png|*.webp|*.gif|*.bmp|*.tif|*.tiff)
            arquivos+=("$arquivo")
            ;;
    esac
done

if [[ ${#arquivos[@]} -eq 0 ]]; then
    echo "Nenhuma imagem encontrada."
    exit 0
fi

# Ordena de forma previsível
mapfile -t arquivos < <(printf '%s\n' "${arquivos[@]}" | sort -V)

destinos=()
i=1

for arquivo in "${arquivos[@]}"; do
    destinos+=("ft${i}.jpeg")
    ((i++))
done

echo "Conversor: $CONVERTER"
echo "Imagens encontradas: ${#arquivos[@]}"
echo
echo "Prévia:"
for idx in "${!arquivos[@]}"; do
    printf '  %s  ->  %s\n' "${arquivos[$idx]}" "${destinos[$idx]}"
done

if ! $RUN; then
    echo
    echo "Nada foi alterado."
    echo "Para executar:"
    echo "  ./$(basename "$0") --run"
    exit 0
fi

mkdir -p "$TMP_DIR"
mkdir -p "$BACKUP_DIR"

echo
echo "Convertendo para JPEG..."

for idx in "${!arquivos[@]}"; do
    origem="${arquivos[$idx]}"
    tmp="$TMP_DIR/${idx}.jpeg"

    if [[ "$CONVERTER" == "ffmpeg" ]]; then
        ffmpeg -y -hide_banner -loglevel error \
            -i "$origem" \
            -frames:v 1 \
            -vf "format=rgb24" \
            -q:v 2 \
            "$tmp"
    else
        "$CONVERTER" "$origem" \
            -auto-orient \
            -background white \
            -alpha remove \
            -alpha off \
            -strip \
            -quality 95 \
            "$tmp"
    fi

    [[ -s "$tmp" ]] || {
        echo "ERRO ao converter: $origem"
        exit 1
    }
done

echo "Movendo originais para backup..."

for arquivo in "${arquivos[@]}"; do
    mv -- "$arquivo" "$BACKUP_DIR/"
done

echo "Criando arquivos finais..."

for idx in "${!destinos[@]}"; do
    destino="${destinos[$idx]}"
    tmp="$TMP_DIR/${idx}.jpeg"

    if [[ -e "$destino" ]]; then
        echo "ERRO: destino já existe: $destino"
        echo "Originais estão em: $BACKUP_DIR"
        echo "Convertidos temporários estão em: $TMP_DIR"
        exit 1
    fi

    mv -- "$tmp" "$destino"
done

rmdir "$TMP_DIR"

echo
echo "Feito."
echo "JPEGs criados: ${#destinos[@]}"
echo "Backup dos originais: $BACKUP_DIR"
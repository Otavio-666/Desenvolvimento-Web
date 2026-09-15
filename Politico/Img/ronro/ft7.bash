i=1

for arquivo in *; do
    [ -f "$arquivo" ] || continue

    ext="${arquivo##*.}"
    mv "$arquivo" "ft${i}.${ext}"

    ((i++))
done
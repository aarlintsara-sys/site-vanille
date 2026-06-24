#!/bin/bash
# Regénère sitemap.xml à partir des fichiers .html présents à la racine.
# Appelé automatiquement par .git/hooks/pre-commit

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE_URL="https://madagascar-vanille.com"
OUT="$REPO_ROOT/sitemap.xml"

priority_for() {
  case "$1" in
    index.html) echo "1.0" ;;
    blog.html)  echo "0.8" ;;
    article-*)  echo "0.7" ;;
    *)          echo "0.5" ;;
  esac
}

freq_for() {
  case "$1" in
    index.html) echo "monthly" ;;
    blog.html)  echo "weekly"  ;;
    *)          echo "monthly" ;;
  esac
}

lastmod_for() {
  local f="$1"
  local d
  d=$(git -C "$REPO_ROOT" log -1 --format="%ai" -- "$f" 2>/dev/null | cut -c1-10)
  [ -z "$d" ] && d=$(date +%Y-%m-%d)
  echo "$d"
}

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

  for f in "$REPO_ROOT"/*.html; do
    name=$(basename "$f")
    # Exclure les fichiers de vérification (Google Search Console, etc.)
    [[ "$name" == google*.html ]] && continue
    lastmod=$(lastmod_for "$name")
    priority=$(priority_for "$name")
    freq=$(freq_for "$name")

    if [ "$name" = "index.html" ]; then
      loc="$BASE_URL/"
    else
      loc="$BASE_URL/$name"
    fi

    printf '\n  <url>\n'
    printf '    <loc>%s</loc>\n'          "$loc"
    printf '    <lastmod>%s</lastmod>\n'  "$lastmod"
    printf '    <changefreq>%s</changefreq>\n' "$freq"
    printf '    <priority>%s</priority>\n' "$priority"
    printf '  </url>\n'
  done

  echo '</urlset>'
} > "$OUT"

count=$(grep -c '<loc>' "$OUT")
echo "sitemap.xml mis à jour — $count page(s) indexée(s)"

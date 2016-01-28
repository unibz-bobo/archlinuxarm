#!/bin/bash
# Indexes all files recursively from a given parent directory and outputs index.html files.

DIRS="$(find "$1" -type d -not -path '*/\.*' | sort | sed 's:/*$::')"

processDirectories() {
  local dirs="$(find "$1" -maxdepth 1 -type d -not -path '*/\.*' | sort)"
  local files="$(find "$1" -maxdepth 1 -type f -not -path '*/\.*' | sort)"
  for dir in $dirs; do
    if [ "$1" = "$dir" ]; then
      echo "Processing $dir ..."
      createIndexHtml "$dir"
    else
      appendDirectory "$dir"
    fi
  done
  for file in $files; do
    if [ "index.html" != "$(basename "$file")" ]; then
      appendFile "$file"
    fi
  done
}

appendDirectory() {
  local fileName="$(basename "$1")"
  local fileDate="$(TZ="UTC" stat -c %y "$1" | cut -f1 -d".")"
  appendToIndexHtmlTable "$(dirname "$1")" "$fileName" "$fileDate UTC" "-"
}

appendFile() {
  local fileName="$(basename "$1")"
  local fileDate="$(TZ="UTC" stat -c %y "$1" | cut -f1 -d".")"
  local fileSize="$(du -h "$1" | cut -f1 | tr ',' '.')"
  appendToIndexHtmlTable "$(dirname "$1")" "$fileName" "$fileDate UTC" "$fileSize"
}

createIndexHtml() {
  local file="$1/index.html"
  cat << EOF > "$file"
<!DOCTYPE html>
<head>
<title>Index of /$1</title>
</head>
<body>
<h1>Index of /$1</h1>
<table>
<thead>
<tr><th>Name</th><th>Last modified</th><th>Size</th></tr>
</thead>
<tbody>
<tr><td><a href='./../index.html'>Parent Directory</a></td><td></td><td>-</td></tr>
</tbody>
</table>
</body>
EOF
}

appendToIndexHtmlTable() {
  local file="$1/index.html"
  local name="$2"
  local lastModified="$3"
  local size="$4"
  if [ -f "$1/$2" ]; then
    local href="./$2"
  else
    local href="./$2/index.html"
  fi
  local tableRow="<tr><td><a href='$href'>$name</a></td><td>$lastModified</td><td>$size</td></tr>"
  sed -i "s|</tbody>|$tableRow\\n</tbody>|" "$file"
}

for dir in $DIRS; do
  processDirectories $dir
done
echo "Done!"
exit 0

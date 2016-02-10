#!/bin/bash

DIRS="$(find "$1" -type d -not -path '*/\.*' | sort | sed 's:/*$::')"

processDirectory() {
  local dir="$1"
  local dirName="$(basename $dir)"
  local packages="$(find "$dir" -maxdepth 1 -name "*.pkg.tar.xz" | wc -l)"
  echo -e "Processing $dir ...\c"
  if [ $packages -gt 0 ]; then
    echo " found $packages packages"
    bash -c "cd $dir; repo-add "$dirName.db.tar.gz" *.pkg.tar.xz; rm "$dirName.db"; cp "$dirName.db.tar.gz" "$dirName.db"; rm *.db.tar.gz.old"
    bash -c "cd $dir; rm "$dirName.files"; cp "$dirName.files.tar.gz" "$dirName.files"; rm *.files.tar.gz.old"
  else
    echo ""
  fi
}

for dir in $DIRS; do
  processDirectory $dir
done
echo "Done!"
exit 0

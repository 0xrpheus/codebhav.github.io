#!/bin/bash

FULLSIZE_DIR="assets/images/photos/fullsize"
THUMBS_DIR="assets/images/photos/thumbs"
PHOTOS_DIR="_photos"

mkdir -p "$FULLSIZE_DIR"
mkdir -p "$THUMBS_DIR"
mkdir -p "$PHOTOS_DIR"

filename_to_title() {
    # replace hyphen w space and capitalize
    echo "$1" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}

if command -v magick &> /dev/null; then
    CONVERT_CMD="magick"
    echo "using ImageMagick v7+"
else
    echo "error: ImageMagick isn't installed."
    exit 1
fi

echo "checking for new photos..."
found_new=0

for file in "$FULLSIZE_DIR"/*.jpg "$FULLSIZE_DIR"/*.jpeg "$FULLSIZE_DIR"/*.png "$FULLSIZE_DIR"/*.JPG "$FULLSIZE_DIR"/*.JPEG "$FULLSIZE_DIR"/*.PNG; do
    # skip if pattern mismatch
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    base="${filename%.*}"
    ext="${filename##*.}"
    
    lowercase_ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    standardized_filename="$base.$lowercase_ext"
    
    if [ "$filename" != "$standardized_filename" ]; then
        echo "standardizing filename: $filename -> $standardized_filename"
        mv "$file" "$FULLSIZE_DIR/$standardized_filename"
        filename="$standardized_filename"
    fi
    
    if [ ! -f "$THUMBS_DIR/$filename" ]; then
        echo "processing new photo: $filename"
        found_new=1
        
        echo "creating thumbnail..."
        $CONVERT_CMD "$FULLSIZE_DIR/$filename" -resize "400x300^" -gravity center -extent 400x300 -quality 85 "$THUMBS_DIR/$filename"
        
        if [ $? -ne 0 ]; then
            echo "error: failed to create thumbnail for $filename"
            continue
        fi
        
        # creating md files
        md_file="$PHOTOS_DIR/$base.md"
        if [ ! -f "$md_file" ]; then
            echo "creating markdown file..."
            title=$(filename_to_title "$base")
            current_date=$(date +"%Y-%m-%d")
            
            cat > "$md_file" << EOF
---
layout: photo
title: "$title"
image: $filename
date: $current_date
---

$title.
EOF
            echo "created $md_file"
        fi
        
        echo "finished processing $filename"
    fi
done

if [ $found_new -eq 0 ]; then
    echo "no new photos found."
else
    echo "successfully processed new photos"
fi

echo "done."
#!/bin/bash

# Use the first argument passed to the script, default to "recup_dirs" if empty
TARGET_DIR="${1:-recup_dirs}"
IMAGE_DEST="images"
AUDIO_DEST="audio"
VIDEO_DEST="videos"
DOCUMENT_DEST="documents"
VIDEO_CHECK_TIMEOUT=30

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

# Create destination directories
mkdir -p "$IMAGE_DEST"
mkdir -p "$AUDIO_DEST"
mkdir -p "$VIDEO_DEST"
mkdir -p "$DOCUMENT_DEST"

echo "Removing unwanted files (text, SWF, MP3, WAV, XML, CR2, M4P, WEBM, F, INI, SH, JAVA, CUE, XMP, H, M3U, URL, APPLE, APE, EPUB, CAM, BPG, ICO, PY, HTML, ZIP, GZ, XHTML, GPG, SQLITE, MOBI, XCF, DAT, PAR2, RAR, DISKIMAGE, ARJ, DAD, AB, RM, EXE, QXD, LNK, PSD, ICC, TS, CLASS, DLL, REG)..."
find "$TARGET_DIR" -type f \( -name "*.txt" -o -name "*.swf" -o -name "*.mp3" -o -name "*.wav" -o -name "*.xml" -o -name "*.cr2" -o -name "*.m4p" -o -name "*.webm" -o -name "*.f" -o -name "*.ini" -o -name "*.sh" -o -name "*.java" -o -name "*.cue" -o -name "*.xmp" -o -name "*.h" -o -name "*.m3u" -o -name "*.url" -o -name "*.apple" -o -name "*.ape" -o -name "*.epub" -o -name "*.cam" -o -name "*.bpg" -o -name "*.ico" -o -name "*.py" -o -name "*.html" -o -name "*.zip" -o -name "*.gz" -o -name "*.xhtml" -o -name "*.gpg" -o -name "*.sqlite" -o -name "*.sqllite" -o -name "*.mobi" -o -name "*.xcf" -o -name "*.dat" -o -name "*.par2" -o -name "*.rar" -o -name "*.diskimage" -o -name "*.arj" -o -name "*.dad" -o -name "*.ab" -o -name "*.rm" -o -name "*.exe" -o -name "*.qxd" -o -name "*.lnk" -o -name "*.psd" -o -name "*.icc" -o -name "*.ts" -o -name "*.class" -o -name "*.dll" -o -name "*.reg" \) -delete

echo "Validating and consolidating videos..."
video_num=0
while IFS= read -r -d '' video; do
    ((video_num++))
    echo "[$video_num] Checking: $(basename "$video")"

    # ffprobe validates headers only; full ffmpeg decode hangs on large/corrupt recovered files
    if timeout "$VIDEO_CHECK_TIMEOUT" ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of csv=p=0 "$video" </dev/null >/dev/null 2>&1; then
        filename=$(basename "$video")
        name="${filename%.*}"
        ext="${filename##*.}"
        dest_path="$VIDEO_DEST/$filename"
        counter=1
        
        while [ -e "$dest_path" ]; do
            dest_path="$VIDEO_DEST/${name}_${counter}.${ext}"
            ((counter++))
        done
        
        mv "$video" "$dest_path"
    else
        echo "Corrupted video found and removed: $video"
        rm -f "$video"
    fi
done < <(find "$TARGET_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.mov" -o -name "*.avi" -o -name "*.3gp" -o -name "*.flv" -o -name "*.mpg" -o -name "*.mpeg" -o -name "*.wmv" \) -print0)

echo "Consolidating valid images and resolving name collisions..."
find "$TARGET_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.jp2" -o -name "*.png" -o -name "*.gif" -o -name "*.bmp" -o -name "*.tif" -o -name "*.tiff" -o -name "*.tf" -o -name "*.tff" -o -name "*.webp" -o -name "*.svg" \) -print0 | while read -r -d '' img; do
    filename=$(basename "$img")
    name="${filename%.*}"
    ext="${filename##*.}"
    dest_path="$IMAGE_DEST/$filename"
    counter=1
    while [ -e "$dest_path" ]; do
        dest_path="$IMAGE_DEST/${name}_${counter}.${ext}"
        ((counter++))
    done
    mv "$img" "$dest_path"
done

echo "Consolidating FLAC audio files and resolving name collisions..."
find "$TARGET_DIR" -type f -name "*.flac" -print0 | while read -r -d '' audio; do
    filename=$(basename "$audio")
    name="${filename%.*}"
    ext="${filename##*.}"
    dest_path="$AUDIO_DEST/$filename"
    counter=1
    while [ -e "$dest_path" ]; do
        dest_path="$AUDIO_DEST/${name}_${counter}.${ext}"
        ((counter++))
    done
    mv "$audio" "$dest_path"
done

echo "Consolidating documents and resolving name collisions..."
find "$TARGET_DIR" -type f \( -name "*.pdf" -o -name "*.odt" -o -name "*.doc" -o -name "*.xls" -o -name "*.xlsx" -o -name "*.ods" -o -name "*.sxc" \) -print0 | while read -r -d '' doc; do
    filename=$(basename "$doc")
    name="${filename%.*}"
    ext="${filename##*.}"
    dest_path="$DOCUMENT_DEST/$filename"
    counter=1
    while [ -e "$dest_path" ]; do
        dest_path="$DOCUMENT_DEST/${name}_${counter}.${ext}"
        ((counter++))
    done
    mv "$doc" "$dest_path"
done

echo "Removing empty subdirectories..."
find "$TARGET_DIR" -mindepth 1 -type d -empty -delete

echo "Cleanup and multi-media consolidation complete."


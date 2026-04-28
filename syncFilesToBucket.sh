#!/bin/bash

# ====== CONFIGURATION ======
LOCAL_DIR="/home/ubuntu/ajay"
S3_BUCKET="s3://sunil-demo2026-s3"
# ===========================

# -------------------------------------------------------
# Helper: Check if a file already exists in S3
# -------------------------------------------------------
file_exists_in_s3() {
    local filename="$1"
    aws s3 ls "${S3_BUCKET}/${filename}" > /dev/null 2>&1
    return $?
}

# -------------------------------------------------------
# Sync a single file passed as argument
# -------------------------------------------------------
sync_single_file() {
    local filename="$1"
    local filepath="${LOCAL_DIR}/${filename}"

    # Check if the file exists in the local directory
    if [ ! -f "$filepath" ]; then
        echo "❌ Error: '${filename}' not found in '${LOCAL_DIR}'."
        exit 1
    fi

    # Check if the file already exists in S3
    if file_exists_in_s3 "$filename"; then
        echo "⚠️  Skipped: '${filename}' already exists in S3. No upload performed."
    else
        echo "⬆️  Uploading: '${filename}' → ${S3_BUCKET}/"
        aws s3 cp "$filepath" "${S3_BUCKET}/${filename}"
        if [ $? -eq 0 ]; then
            echo "✅ Success: '${filename}' uploaded successfully!"
        else
            echo "❌ Failed: Could not upload '${filename}'. Please check your AWS credentials and bucket name."
            exit 1
        fi
    fi
}

# -------------------------------------------------------
# Sync all files in the local directory
# -------------------------------------------------------
sync_all_files() {
    echo "🔍 Scanning all files in '${LOCAL_DIR}'..."
    echo ""

    local total=0
    local uploaded=0
    local skipped=0

    # Loop through files only (skip subdirectories)
    for filepath in "${LOCAL_DIR}"/*; do
        [ -f "$filepath" ] || continue

        filename=$(basename "$filepath")
        total=$((total + 1))

        if file_exists_in_s3 "$filename"; then
            echo "⚠️  Skipped: '${filename}' already exists in S3."
            skipped=$((skipped + 1))
        else
            echo "⬆️  Uploading: '${filename}'..."
            aws s3 cp "$filepath" "${S3_BUCKET}/${filename}"
            if [ $? -eq 0 ]; then
                echo "✅ Uploaded: '${filename}'"
                uploaded=$((uploaded + 1))
            else
                echo "❌ Failed:   '${filename}'"
            fi
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Summary:"
    echo "   Total files found : $total"
    echo "   Uploaded          : $uploaded"
    echo "   Skipped (exist)   : $skipped"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# -------------------------------------------------------
# MAIN: Check arguments and decide what to run
# -------------------------------------------------------
if [ $# -eq 1 ]; then
    sync_single_file "$1"
elif [ $# -eq 0 ]; then
    sync_all_files
else
    echo "❌ Invalid usage."
    echo ""
    echo "Usage:"
    echo "   ./syncFilesToBucket.sh                → Sync all files to S3"
    echo "   ./syncFilesToBucket.sh <filename>     → Sync a specific file to S3"
    echo ""
    echo "Examples:"
    echo "   ./syncFilesToBucket.sh"
    echo "   ./syncFilesToBucket.sh dummy.pdf"
    exit 1
fi

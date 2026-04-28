#!/bin/bash

# ====== CONFIGURATION ======
S3_BUCKET="s3://sunil-demo2026-s3"
# ===========================

# -------------------------------------------------------
# Argument is mandatory — exit if not provided
# -------------------------------------------------------
if [ $# -ne 1 ]; then
    echo "Missing argument. A filename is required."
    echo ""
    echo "Usage:"
    echo "   ./getFileFromBucket.sh <filename>"
    echo ""
    echo "Example:"
    echo "   ./getFileFromBucket.sh dummy.pdf"
    exit 1
fi

FILENAME="$1"
CURRENT_DIR="$(pwd)"
LOCAL_FILEPATH="${CURRENT_DIR}/${FILENAME}"

# -------------------------------------------------------
# Check if the file already exists in the current directory
# -------------------------------------------------------
if [ -f "$LOCAL_FILEPATH" ]; then
    echo " '${FILENAME}' already exists in the current directory. Nothing to do."
    echo "   Location: ${LOCAL_FILEPATH}"
    exit 0
fi

# -------------------------------------------------------
# Check if the file exists in S3
# -------------------------------------------------------
echo "Looking for '${FILENAME}' in S3 bucket..."
aws s3 ls "${S3_BUCKET}/${FILENAME}" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo " Error: '${FILENAME}' not found in S3 bucket."
    echo "   Bucket: ${S3_BUCKET}"
    echo "   Please upload the file first using syncFilesToBucket.sh"
    exit 1
fi

# -------------------------------------------------------
# Download the file from S3 to the current directory
# -------------------------------------------------------
echo " Downloading: '${FILENAME}' → ${CURRENT_DIR}/"
aws s3 cp "${S3_BUCKET}/${FILENAME}" "${LOCAL_FILEPATH}"

if [ $? -eq 0 ]; then
    echo " Success: '${FILENAME}' downloaded successfully!"
    echo "   Location: ${LOCAL_FILEPATH}"
else
    echo " Failed: Could not download '${FILENAME}'. Please check your AWS credentials and bucket name."
    exit 1
fi

# AWS S3 File Sync Scripts

Two bash scripts to sync files between a local Linux directory and an AWS S3 bucket.

## Setup

### 1. Prerequisites
Make sure AWS CLI is installed and configured on your machine:
```bash
sudo apt update && sudo apt install awscli -y
aws configure   # Enter your Access Key, Secret Key, Region
```

### 2. Clone this repository
```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 3. Make scripts executable
```bash
chmod +x syncFilesToBucket.sh
chmod +x getFileFromBucket.sh
```

---

## Scripts

### syncFilesToBucket.sh
Uploads files from your local directory (`/home/ubuntu/ajay`) to the S3 bucket (`sunil-demo2026-s3`).

- If **no argument** is passed → uploads **all files** in the directory (skips files already in S3)
- If a **filename is passed** → uploads only that specific file (skips if already in S3)

**Usage:**
```bash
# Sync all files
./syncFilesToBucket.sh

# Sync a specific file
./syncFilesToBucket.sh dummy.pdf
```

**Example Output:**
```
Scanning all files in '/home/ubuntu/ajay'...

Uploading: 'report.pdf'...
Uploaded: 'report.pdf'
Skipped: 'notes.txt' already exists in S3.

Summary:
   Total files found : 2
   Uploaded          : 1
   Skipped (exist)   : 1
```

---

### getFileFromBucket.sh
Downloads a file from S3 to your **current directory**.

- If the file **already exists locally** → does nothing
- If the file **does not exist locally** → downloads it from S3
- If the file **is not found in S3** → shows an error

**Usage:**
```bash
./getFileFromBucket.sh <filename>

# Example
./getFileFromBucket.sh dummy.pdf
```

**Example Output:**
```
Looking for 'dummy.pdf' in S3 bucket...
Downloading: 'dummy.pdf' to current directory
Success: 'dummy.pdf' downloaded successfully!
Location: /home/ubuntu/ajay/dummy.pdf
```

---

## Configuration

| Variable | Value |
|----------|-------|
| `LOCAL_DIR` | `/home/ubuntu/ajay` |
| `S3_BUCKET` | `s3://sunil-demo2026-s3` |

To change the directory or bucket, edit the `# CONFIGURATION` section at the top of each script.

---

## Logic Summary

| Script | Condition | Result |
|--------|-----------|--------|
| `syncFilesToBucket.sh` | File already exists in S3 | Skipped |
| `syncFilesToBucket.sh` | File does not exist in S3 | Uploaded |
| `getFileFromBucket.sh` | File already exists locally | Nothing done |
| `getFileFromBucket.sh` | File not local, exists in S3 | Downloaded |
| `getFileFromBucket.sh` | File not found in S3 | Error shown |

#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 input.pdf"
    exit 1
fi

# Check if required tools are installed
for cmd in pdftoppm tesseract ospeak ffmpeg parallel; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Configuration
INPUT_PDF="$1"
BASE_NAME=$(basename "$INPUT_PDF" .pdf)
OUTPUT_PDF="${BASE_NAME}_clean.pdf"
OUTPUT_TEXT="${BASE_NAME}"
OUTPUT_AUDIO="${BASE_NAME}.mp3"
TEMP_DIR="tmp_${BASE_NAME}"
VOICE="fable"
MODEL="tts-1-hd"

# Create temporary directory
mkdir -p "$TEMP_DIR" || { echo "Failed to create temp directory"; exit 1; }

# Function to clean up temporary files
cleanup() {
    rm -rf "$TEMP_DIR"
}

# Trap errors and cleanup
trap cleanup EXIT

# Step 1: Convert PDF to images
echo "Converting PDF to images..."
pdftoppm "$INPUT_PDF" "${TEMP_DIR}/tmp_image" -png -r 600 || { echo "PDF conversion failed"; exit 1; }

# Step 2: Create image list
echo "Creating image list..."
find "${TEMP_DIR}" -name "tmp_image*.png" | sort > "${TEMP_DIR}/images.txt" || { echo "Failed to create image list"; exit 1; }

# Step 3: OCR images
echo "Performing OCR..."
# Run PDF and text OCR in parallel
tesseract "${TEMP_DIR}/images.txt" "${TEMP_DIR}/output" -l eng pdf &
PDF_PID=$!
tesseract "${TEMP_DIR}/images.txt" "$OUTPUT_TEXT" -l eng txt &
TXT_PID=$!

# Wait for both OCR processes to complete
wait $PDF_PID || { echo "PDF OCR failed"; exit 1; }
wait $TXT_PID || { echo "Text OCR failed"; exit 1; }

# Move cleaned PDF to output
mv "${TEMP_DIR}/output.pdf" "$OUTPUT_PDF" || { echo "Failed to move cleaned PDF"; exit 1; }

# Step 4: Split text into 4096-character chunks
echo "Splitting text into chunks..."
split -b 4096 "${OUTPUT_TEXT}.txt" "${TEMP_DIR}/chunk_" || { echo "Text splitting failed"; exit 1; }

# Step 5: Convert each chunk to audio in parallel
echo "Converting text chunks to audio in parallel..."
find "${TEMP_DIR}" -name "chunk_*" -exec sh -c 'echo "{}"' \; | parallel --eta --progress "cat {} | ospeak -o {}.mp3 -v $VOICE -m $MODEL" || { echo "Audio conversion failed"; exit 1; }

# Step 6: Create file list for concatenation
echo "Preparing audio concatenation..."
> "${TEMP_DIR}/files.txt"
find "${TEMP_DIR}" -name "chunk_*.mp3" -exec sh -c 'echo "file $(realpath "{}")"' \; | sort >> "${TEMP_DIR}/files.txt" || { echo "Failed to create file list"; exit 1; }

# Step 7: Concatenate audio files
echo "Concatenating audio files..."
ffmpeg -f concat -safe 0 -i "${TEMP_DIR}/files.txt" -c copy "$OUTPUT_AUDIO" || { echo "Audio concatenation failed"; exit 1; }

echo "Audiobook created: $OUTPUT_AUDIO"
echo "Cleaned PDF created: $OUTPUT_PDF"
echo "Text file created: $OUTPUT_TEXT.txt"
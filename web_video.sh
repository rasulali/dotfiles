#!/bin/sh

# Default values
input_file=""
output_file_base="background_video"

# Function to display usage
usage() {
    echo "Usage: $0 -i <input_file> [-o <output_file_base>]"
    echo "  -i: Input file (required)"
    echo "  -o: Output file base name (optional, default: background_video)"
    exit 1
}

# Parse command line arguments
while getopts "i:o:" opt; do
    case $opt in
        i) input_file="$OPTARG";;
        o) output_file_base="$OPTARG";;
        *) usage;;
    esac
done

# Check if input file is provided
if [ -z "$input_file" ]; then
    echo "Error: Input file is required"
    usage
fi

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' does not exist"
    exit 1
fi

# Export H.264 MP4 (for Apple devices)
ffmpeg -i "$input_file" \
    -c:v libx264 -preset slow -crf 23 \
    -vf "scale=1920:1080,fps=30" \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    "${output_file_base}_apple.mp4"

# Export VP9 WebM (for everything else)
ffmpeg -i "$input_file" \
    -c:v libvpx-vp9 -crf 30 -b:v 0 \
    -vf "scale=1920:1080,fps=30" \
    -c:a libopus -b:a 128k \
    "${output_file_base}_other.webm"

echo "Export complete. Output files:"
echo "- ${output_file_base}_apple.mp4"
echo "- ${output_file_base}_other.webm"

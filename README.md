# PDF to Audiobook Converter

This Bash script converts a PDF into an audiobook (MP3), a cleaned PDF, and a text file by performing OCR, and text-to-speech conversion with OpenAI's TTS.

## Dependencies
The script relies on the following tools:
- [pdftoppm](https://poppler.freedesktop.org/) (part of Poppler) - Converts PDF to images
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) - Performs optical character recognition
- [FFmpeg](https://github.com/FFmpeg/FFmpeg) - Concatenates audio files
- [ospeak](https://github.com/simonw/ospeak) - Text-to-speech conversion
- [parallel](https://www.gnu.org/software/parallel/sphinx.html) - Parallel processing

## Prerequisites
Get an [OpenAI API key](https://platform.openai.com).

Follow these steps to set up the prerequisites for the script on macOS:

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install FFmpeg**:
   ```bash
   brew install ffmpeg
   ```

3. **Install Poppler (for pdftoppm)**:
   ```bash
   brew install poppler
   ```

4. **Install Tesseract OCR**:
   ```bash
   brew install tesseract
   ```

5. **Install parallel**:
   ```bash
   brew install parallel
   ```

6. **Install Python 3.11**:
   ```bash
   brew install python@3.11
   ```

7. **Install pipx**:
   ```bash
   brew install pipx
   ```

8. **Install ospeak using pipx**:
   ```bash
   pipx install --python /opt/homebrew/bin/python3.11 ospeak
   ```

9. **Ensure ospeak is on your PATH**:
   - Run the following command to add pipx binaries to your PATH:
     ```bash
     pipx ensurepath
     ```
   - Restart your terminal or source your shell configuration file (e.g., `source ~/.zshrc` or `source ~/.bashrc`).

10. **Set Your OpenAI API key**:
   ```bash
   export OPENAI_API_KEY="..."
   ```

## Usage
1. Save the script as `pdf_to_audiobook.sh`.
2. Make it executable:
   ```bash
   chmod +x pdf_to_audiobook.sh
   ```
3. Run the script with a PDF file as input:
   ```bash
   ./pdf_to_audiobook.sh input.pdf
   ```

## Output
The script will generate:
- A cleaned PDF: `<input>_clean.pdf`
- A text file: `<input>.txt`
- An audiobook: `<input>.mp3`

## Notes
- The script uses the `fable` voice and `tts-1-hd` model for text-to-speech via `ospeak`. Ensure you have the necessary API keys configured for `ospeak` (refer to the [ospeak GitHub repository](https://github.com/simonw/ospeak) for setup details).
- Temporary files are created in a `tmp_<input>` directory and automatically cleaned up upon completion or if the script is interrupted.
- The script splits text into 4096-character chunks to handle large documents efficiently.

## Troubleshooting
- **Command not found**: Ensure all tools (`pdftoppm`, `tesseract`, `ffmpeg`, `ospeak`, `parallel`) are installed and on your PATH.
- **Permission denied**: Ensure the script is executable (`chmod +x pdf_to_audiobook.sh`) and you have write permissions in the working directory.
- **ospeak errors**: Verify that `ospeak` is installed with Python 3.11 and configured correctly. Check the [ospeak documentation](https://github.com/simonw/ospeak) for additional setup steps.

## License
This script is provided under the MIT License. See the [LICENSE](LICENSE) file for details.
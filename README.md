# BananaMic (Voice-to-LLM)

BananaMic is an ultra-lightweight (< 1MB) native macOS menu bar utility designed for a single powerful workflow: **Recording high-quality, lossless audio instantly to your clipboard, ready to be pasted directly into advanced LLMs like Gemini.**

## Why not real-time speech recognition?
Native macOS dictation and traditional speech-to-text tools process audio in real-time. This often leads to poor transcription quality, missed context, and struggling with complex technical phrasing or punctuation. 

Modern Large Language Models (like Google Gemini) have incredibly powerful multimodal backends. By providing the LLM with the raw audio file, you leverage a significantly superior backend that understands deep context, nuances, technical jargon, and intent much better than a real-time dictation service. 

BananaMic acts as the missing bridge: it gives you a 1-click native interface to capture your thoughts and instantly puts the audio file in your clipboard, ready to be pasted (`Cmd + V`) into your LLM chat window.

## Features
- **Zero Friction**: Sits quietly in your macOS menu bar. 1-click to start recording, 1-click to stop.
- **Native Clipboard Integration**: The moment you stop recording, the `.m4a` file is automatically placed in your macOS clipboard as a native file reference. Just paste it anywhere.
- **High Quality Audio**: Uses Apple's native `AVAudioRecorder` to capture crystal clear AAC (`.m4a`) audio directly from your default microphone.
- **Ultra Lightweight**: Built 100% natively in Swift without Xcode or heavy frameworks (like Electron). The entire app is less than 1MB and uses virtually zero background resources.
- **Screen Capture Shortcut**: Includes a quick shortcut to summon the native macOS Screen Capture UI (`Cmd+Shift+5`), perfect for grabbing visual context to send alongside your audio to the LLM.

## Installation & Build
No Xcode required! You can compile this app natively using the tools already built into your Mac.

1. Clone this repository.
2. Open your terminal and navigate to the folder.
3. Run the build script:
   ```bash
   sh build.sh
   ```
4. A `BananaMic.app` file will be instantly generated. Drag it to your `Applications` folder and double-click to launch!

## Usage
1. Click the gear icon in the menu bar.
2. Select **Quick Audio Record** (or just left-click the icon).
3. The icon will flash a red dot indicating it is recording. Speak your thoughts naturally.
4. Left-click the icon again to stop.
5. Go to your Gemini (or other LLM) browser tab and press `Cmd + V` to upload the audio file.

## Requirements
- macOS 11.0 or later (Apple Silicon native).
- Microphone permissions (macOS will prompt you on first use).

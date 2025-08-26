# AI Transcription & Summary iOS App

A hybrid iOS app that provides both local and cloud-based audio transcription with speaker diarization and intelligent meeting summaries.

## Features

### 🎤 Audio Processing
- **Local Recording**: High-quality audio recording within the app
- **File Import**: Support for MP3, WAV, M4A, and other audio formats
- **Audio Preview**: Playback, trim, and basic editing capabilities

### 🧠 Processing Modes
- **Basic Mode (Free)**: Local processing using CoreML and Whisper
- **Advanced Mode (Paid)**: Cloud processing for professional quality
- **Smart Recommendations**: AI suggests optimal processing mode

### 📝 Transcription & Analysis
- **Whisper Integration**: OpenAI Whisper for accurate transcription
- **Speaker Diarization**: Identify and label different speakers
- **Real-time Processing**: Live transcription during recording
- **Background Processing**: Queue system for long recordings

### 📋 Summary Generation
- **Template System**: Pre-built templates for different meeting types
- **Custom Templates**: User-defined summary structures
- **AI Summaries**: Intelligent meeting summarization
- **Export Options**: Word documents, plain text, and more

### 💾 Storage & Export
- **Local Storage**: Core Data for transcripts and summaries
- **Cloud Backup**: Optional cloud storage for advanced users
- **Export Formats**: Multiple format support for sharing
- **Notion Integration**: Direct export to Notion (future feature)

## Technical Architecture

### Frontend
- **SwiftUI**: Modern iOS interface
- **Combine**: Reactive programming
- **Core Data**: Local data persistence

### Audio Processing
- **AVFoundation**: Audio recording and playback
- **Core Audio**: Advanced audio processing
- **Whisper CoreML**: Local transcription models

### Cloud Services
- **AWS Lambda**: Serverless processing
- **S3**: File storage
- **SQS**: Processing queue management

## Project Structure

```
AI Transcription/
├── iOS App/
│   ├── Views/
│   ├── Models/
│   ├── ViewModels/
│   ├── Services/
│   └── Utilities/
├── Cloud Infrastructure/
│   ├── Lambda Functions/
│   ├── API Gateway/
│   └── Processing Pipeline/
└── Documentation/
```

## Getting Started

1. Clone the repository
2. Open `AI Transcription.xcodeproj` in Xcode
3. Install required dependencies
4. Configure cloud services (optional for local-only mode)
5. Build and run on iOS device or simulator

## Dependencies

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- CoreML
- AVFoundation
- Core Data

## License

MIT License - see LICENSE file for details

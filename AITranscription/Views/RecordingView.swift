import SwiftUI
import AVFoundation

struct RecordingView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var transcriptionService = TranscriptionService()
    @StateObject private var summaryService = SummaryService()
    
    @State private var showingFileImporter = false
    @State private var showingProcessingOptions = false
    @State private var selectedProcessingMode: Transcript.ProcessingMode?
    @State private var selectedTemplate: SummaryTemplate = .oneOnOne
    @State private var showingTemplateSelection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("AI Transcription")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Record audio or import files for transcription")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Recording Interface
                VStack(spacing: 20) {
                    // Audio Level Visualization
                    if audioRecorder.isRecording {
                        AudioLevelView(audioLevel: audioRecorder.audioLevel)
                            .frame(height: 100)
                    }
                    
                    // Recording Controls
                    HStack(spacing: 30) {
                        // Import Button
                        Button(action: {
                            showingFileImporter = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "folder.badge.plus")
                                    .font(.system(size: 30))
                                Text("Import")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                        .disabled(audioRecorder.isRecording)
                        
                        // Record Button
                        Button(action: {
                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording()
                            } else {
                                audioRecorder.startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Play Button
                        Button(action: {
                            if let audioFile = audioRecorder.currentAudioFile {
                                if audioRecorder.isPlaying {
                                    audioRecorder.stopPlayback()
                                } else {
                                    audioRecorder.playAudio(from: audioFile.fileURL)
                                }
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: audioRecorder.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 30))
                                Text("Play")
                                    .font(.caption)
                            }
                            .foregroundColor(.green)
                        }
                        .disabled(audioRecorder.currentAudioFile == nil)
                    }
                    
                    // Recording Time
                    if audioRecorder.isRecording {
                        Text(audioRecorder.getFormattedRecordingTime())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Current Audio File Info
                if let audioFile = audioRecorder.currentAudioFile {
                    AudioFileInfoView(audioFile: audioFile)
                    
                    // Processing Options
                    VStack(spacing: 15) {
                        Text("Ready to Process")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            // Basic Processing (Free)
                            ProcessingModeButton(
                                mode: .basic,
                                title: "Basic (Free)",
                                subtitle: "Local processing",
                                icon: "cpu",
                                color: .green
                            ) {
                                selectedProcessingMode = .basic
                                showingTemplateSelection = true
                            }
                            
                            // Advanced Processing (Paid)
                            ProcessingModeButton(
                                mode: .advanced,
                                title: "Advanced (Paid)",
                                subtitle: "Cloud processing",
                                icon: "cloud",
                                color: .blue
                            ) {
                                selectedProcessingMode = .advanced
                                showingTemplateSelection = true
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                
                // Error Message
                if let errorMessage = audioRecorder.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    audioRecorder.importAudioFile(from: url)
                }
            case .failure(let error):
                audioRecorder.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $showingTemplateSelection) {
            TemplateSelectionView(
                selectedTemplate: $selectedTemplate,
                onTemplateSelected: { template in
                    selectedTemplate = template
                    showingTemplateSelection = false
                    startProcessing()
                }
            )
        }
    }
    
    private func startProcessing() {
        guard let audioFile = audioRecorder.currentAudioFile,
              let processingMode = selectedProcessingMode else { return }
        
        Task {
            // Start transcription
            let transcript = await transcriptionService.processAudio(
                audioFile: audioFile,
                preferredMode: processingMode
            )
            
            if let transcript = transcript {
                // Generate summary
                let summary = await summaryService.generateSummary(
                    for: transcript,
                    template: selectedTemplate,
                    processingMode: processingMode
                )
                
                // Update audio file with results
                await MainActor.run {
                    audioRecorder.currentAudioFile?.transcript = transcript
                    audioRecorder.currentAudioFile?.summary = summary
                    audioRecorder.currentAudioFile?.processingStatus = .completed
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct AudioLevelView: View {
    let audioLevel: Float
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 4, height: max(4, CGFloat(audioLevel + 60) * 2))
                    .animation(.easeInOut(duration: 0.1), value: audioLevel)
            }
        }
    }
}

struct AudioFileInfoView: View {
    let audioFile: AudioFile
    
    var body: some View {
        VStack(spacing: 10) {
            Text(audioFile.fileName)
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 20) {
                InfoItem(title: "Duration", value: audioFile.formattedDuration)
                InfoItem(title: "Size", value: audioFile.formattedFileSize)
                InfoItem(title: "Format", value: audioFile.audioFormat.displayName)
            }
            
            Text(audioFile.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ProcessingModeButton: View {
    let mode: Transcript.ProcessingMode
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RecordingView()
}

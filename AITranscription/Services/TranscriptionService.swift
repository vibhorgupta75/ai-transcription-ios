import Foundation
import Combine
import AVFoundation

class TranscriptionService: ObservableObject {
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0
    @Published var currentStatus = ""
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Local processing (free)
    func processLocally(audioFile: AudioFile) async -> Transcript? {
        await MainActor.run {
            isProcessing = true
            processingProgress = 0
            currentStatus = "Starting local transcription..."
        }
        
        // Simulate local processing steps
        await updateProgress(0.2, "Loading Whisper model...")
        await updateProgress(0.4, "Transcribing audio...")
        await updateProgress(0.6, "Detecting speakers...")
        await updateProgress(0.8, "Finalizing transcript...")
        await updateProgress(1.0, "Transcription complete!")
        
        // For now, return a mock transcript
        // In production, this would use CoreML with Whisper
        let mockTranscript = createMockTranscript(for: audioFile, mode: .basic)
        
        await MainActor.run {
            isProcessing = false
            processingProgress = 0
            currentStatus = ""
        }
        
        return mockTranscript
    }
    
    // Cloud processing (paid)
    func processInCloud(audioFile: AudioFile) async -> Transcript? {
        await MainActor.run {
            isProcessing = true
            processingProgress = 0
            currentStatus = "Starting cloud transcription..."
        }
        
        // Simulate cloud processing steps
        await updateProgress(0.1, "Uploading audio file...")
        await updateProgress(0.3, "Processing with Whisper API...")
        await updateProgress(0.5, "Running speaker diarization...")
        await updateProgress(0.7, "Generating enhanced transcript...")
        await updateProgress(0.9, "Finalizing results...")
        await updateProgress(1.0, "Transcription complete!")
        
        // For now, return a mock transcript
        // In production, this would call cloud APIs
        let mockTranscript = createMockTranscript(for: audioFile, mode: .advanced)
        
        await MainActor.run {
            isProcessing = false
            processingProgress = 0
            currentStatus = ""
        }
        
        return mockTranscript
    }
    
    // Hybrid processing - choose best mode based on audio length
    func processAudio(audioFile: AudioFile, preferredMode: Transcript.ProcessingMode? = nil) async -> Transcript? {
        let recommendedMode = preferredMode ?? recommendProcessingMode(for: audioFile)
        
        switch recommendedMode {
        case .basic:
            return await processLocally(audioFile: audioFile)
        case .advanced:
            return await processInCloud(audioFile: audioFile)
        }
    }
    
    // Recommend processing mode based on audio characteristics
    func recommendProcessingMode(for audioFile: AudioFile) -> Transcript.ProcessingMode {
        // Recommend basic mode for short recordings
        if audioFile.duration < 300 { // Less than 5 minutes
            return .basic
        }
        
        // Recommend advanced mode for longer recordings
        if audioFile.duration > 900 { // More than 15 minutes
            return .advanced
        }
        
        // For medium recordings, let user choose
        return .basic
    }
    
    // Estimate cost for cloud processing
    func estimateCloudCost(for audioFile: AudioFile) -> Double {
        let minutes = audioFile.duration / 60
        
        // OpenAI Whisper pricing (approximate)
        let whisperCost = minutes * 0.006
        let speakerDetectionCost = minutes * 0.015
        let totalCost = whisperCost + speakerDetectionCost
        
        return totalCost
    }
    
    // Get processing time estimate
    func estimateProcessingTime(for audioFile: AudioFile, mode: Transcript.ProcessingMode) -> TimeInterval {
        let minutes = audioFile.duration / 60
        
        switch mode {
        case .basic:
            // Local processing: 2-5 minutes for most recordings
            return min(max(minutes * 0.5, 120), 300)
        case .advanced:
            // Cloud processing: 1-3 minutes for most recordings
            return min(max(minutes * 0.2, 60), 180)
        }
    }
    
    private func updateProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            processingProgress = progress
            currentStatus = status
        }
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
    }
    
    // Mock transcript generation for development
    private func createMockTranscript(for audioFile: AudioFile, mode: Transcript.ProcessingMode) -> Transcript {
        let duration = audioFile.duration
        let segmentCount = Int(duration / 10) // One segment every 10 seconds
        
        var segments: [TranscriptSegment] = []
        
        for i in 0..<segmentCount {
            let startTime = TimeInterval(i * 10)
            let endTime = startTime + 10
            
            let speaker: String?
            if mode == .advanced {
                // Advanced mode includes speaker detection
                speaker = "Speaker \(i % 3 + 1)"
            } else {
                // Basic mode has no speaker detection
                speaker = nil
            }
            
            let mockText = generateMockText(for: i)
            let segment = TranscriptSegment(
                startTime: startTime,
                endTime: endTime,
                text: mockText,
                speaker: speaker,
                confidence: 0.9
            )
            
            segments.append(segment)
        }
        
        let confidence: Double = mode == .advanced ? 0.95 : 0.85
        
        return Transcript(
            audioFileId: audioFile.id,
            processingMode: mode,
            segments: segments,
            confidence: confidence
        )
    }
    
    private func generateMockText(for index: Int) -> String {
        let mockSentences = [
            "This is a sample transcription for development purposes.",
            "The audio recording contains various topics and discussions.",
            "We can see how the transcription service works in practice.",
            "Speaker identification helps distinguish between participants.",
            "The quality of transcription depends on the processing mode.",
            "Local processing is free but may have lower accuracy.",
            "Cloud processing provides better results but costs money.",
            "Users can choose between speed and quality based on their needs.",
            "This mock data helps test the user interface and workflow.",
            "In production, this would contain actual transcribed content."
        ]
        
        return mockSentences[index % mockSentences.count]
    }
}

// MARK: - Processing Status
extension TranscriptionService {
    enum ProcessingStep: String, CaseIterable {
        case uploading = "Uploading audio file"
        case processing = "Processing with Whisper"
        case diarization = "Detecting speakers"
        case finalizing = "Finalizing transcript"
        case complete = "Transcription complete"
        
        var progress: Double {
            let index = Double(ProcessingStep.allCases.firstIndex(of: self) ?? 0)
            return index / Double(ProcessingStep.allCases.count - 1)
        }
    }
}

import Foundation

struct Transcript: Identifiable, Codable {
    let id: UUID
    let audioFileId: UUID
    let createdAt: Date
    let processingMode: ProcessingMode
    let segments: [TranscriptSegment]
    let confidence: Double
    let language: String
    
    enum ProcessingMode: String, Codable, CaseIterable {
        case basic = "basic"
        case advanced = "advanced"
        
        var displayName: String {
            switch self {
            case .basic: return "Basic (Local)"
            case .advanced: return "Advanced (Cloud)"
            }
        }
        
        var cost: String {
            switch self {
            case .basic: return "Free"
            case .advanced: return "Paid"
            }
        }
    }
    
    var fullText: String {
        segments.map { $0.text }.joined(separator: " ")
    }
    
    var speakerCount: Int {
        Set(segments.compactMap { $0.speaker }).count
    }
    
    var duration: TimeInterval {
        segments.last?.endTime ?? 0
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(audioFileId: UUID, processingMode: ProcessingMode, segments: [TranscriptSegment], confidence: Double, language: String = "en") {
        self.id = UUID()
        self.audioFileId = audioFileId
        self.createdAt = Date()
        self.processingMode = processingMode
        self.segments = segments
        self.confidence = confidence
        self.language = language
    }
}

struct TranscriptSegment: Identifiable, Codable {
    let id: UUID
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    let speaker: String?
    let confidence: Double
    
    var duration: TimeInterval {
        endTime - startTime
    }
    
    var formattedStartTime: String {
        let minutes = Int(startTime) / 60
        let seconds = Int(startTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedEndTime: String {
        let minutes = Int(endTime) / 60
        let seconds = Int(endTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(startTime: TimeInterval, endTime: TimeInterval, text: String, speaker: String? = nil, confidence: Double = 1.0) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.speaker = speaker
        self.confidence = confidence
    }
}

import Foundation
import SwiftUI

struct AudioFile: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let duration: TimeInterval
    let fileSize: Int64
    let recordingDate: Date
    let audioFormat: AudioFormat
    var processingStatus: ProcessingStatus
    var transcript: Transcript?
    var summary: Summary?
    
    enum AudioFormat: String, Codable, CaseIterable {
        case mp3 = "mp3"
        case wav = "wav"
        case m4a = "m4a"
        case aac = "aac"
        
        var displayName: String {
            switch self {
            case .mp3: return "MP3"
            case .wav: return "WAV"
            case .m4a: return "M4A"
            case .aac: return "AAC"
            }
        }
    }
    
    enum ProcessingStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .processing: return "Processing"
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .processing: return .blue
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
    
    init(fileName: String, fileURL: URL, duration: TimeInterval, fileSize: Int64, audioFormat: AudioFormat) {
        self.id = UUID()
        self.fileName = fileName
        self.fileURL = fileURL
        self.duration = duration
        self.fileSize = fileSize
        self.recordingDate = Date()
        self.audioFormat = audioFormat
        self.processingStatus = .pending
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: recordingDate)
    }
}

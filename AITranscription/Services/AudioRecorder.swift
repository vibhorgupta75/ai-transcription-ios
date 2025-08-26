import Foundation
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var currentAudioFile: AudioFile?
    @Published var errorMessage: String?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var audioLevelTimer: Timer?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            errorMessage = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            startRecordingTimer()
            startAudioLevelMonitoring()
            
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        stopRecordingTimer()
        stopAudioLevelMonitoring()
        
        if let recorder = audioRecorder,
           let url = recorder.url {
            createAudioFile(from: url)
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }
    
    private func stopAudioLevelMonitoring() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        audioLevel = 0
    }
    
    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        audioLevel = recorder.averagePower(forChannel: 0)
    }
    
    private func createAudioFile(from url: URL) {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes?[.size] as? Int64 ?? 0
        
        let audioFile = AudioFile(
            fileName: url.lastPathComponent,
            fileURL: url,
            duration: recordingTime,
            fileSize: fileSize,
            audioFormat: .m4a
        )
        
        currentAudioFile = audioFile
    }
    
    func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to play audio: \(error.localizedDescription)"
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func importAudioFile(from url: URL) {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes?[.size] as? Int64 ?? 0
        
        // Get audio duration
        let asset = AVAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        
        // Determine format
        let pathExtension = url.pathExtension.lowercased()
        let audioFormat: AudioFile.AudioFormat
        switch pathExtension {
        case "mp3": audioFormat = .mp3
        case "wav": audioFormat = .wav
        case "m4a": audioFormat = .m4a
        case "aac": audioFormat = .aac
        default: audioFormat = .m4a
        }
        
        let audioFile = AudioFile(
            fileName: url.lastPathComponent,
            fileURL: url,
            duration: duration,
            fileSize: fileSize,
            audioFormat: audioFormat
        )
        
        currentAudioFile = audioFile
    }
    
    func deleteAudioFile(_ audioFile: AudioFile) {
        do {
            try FileManager.default.removeItem(at: audioFile.fileURL)
            if currentAudioFile?.id == audioFile.id {
                currentAudioFile = nil
            }
        } catch {
            errorMessage = "Failed to delete audio file: \(error.localizedDescription)"
        }
    }
    
    func getFormattedRecordingTime() -> String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            errorMessage = "Recording failed to complete successfully"
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            errorMessage = "Recording error: \(error.localizedDescription)"
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            errorMessage = "Playback error: \(error.localizedDescription)"
        }
        isPlaying = false
    }
}

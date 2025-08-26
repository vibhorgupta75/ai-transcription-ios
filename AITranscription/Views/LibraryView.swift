import SwiftUI

struct LibraryView: View {
    @State private var audioFiles: [AudioFile] = []
    @State private var searchText = ""
    @State private var selectedFilter: ProcessingStatusFilter = .all
    @State private var showingDetailView = false
    @State private var selectedAudioFile: AudioFile?
    
    enum ProcessingStatusFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case processing = "Processing"
        case completed = "Completed"
        case failed = "Failed"
        
        var color: Color {
            switch self {
            case .all: return .primary
            case .pending: return .orange
            case .processing: return .blue
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
    
    var filteredAudioFiles: [AudioFile] {
        var filtered = audioFiles
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { audioFile in
                audioFile.fileName.localizedCaseInsensitiveContains(searchText) ||
                audioFile.transcript?.fullText.localizedCaseInsensitiveContains(searchText) == true ||
                audioFile.summary?.content.title.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply status filter
        if selectedFilter != .all {
            filtered = filtered.filter { audioFile in
                switch selectedFilter {
                case .pending: return audioFile.processingStatus == .pending
                case .processing: return audioFile.processingStatus == .processing
                case .completed: return audioFile.processingStatus == .completed
                case .failed: return audioFile.processingStatus == .failed
                case .all: return true
                }
            }
        }
        
        return filtered.sorted { $0.recordingDate > $1.recordingDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search recordings, transcripts, or summaries...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ProcessingStatusFilter.allCases, id: \.self) { filter in
                                FilterPill(
                                    filter: filter,
                                    isSelected: selectedFilter == filter,
                                    count: getCount(for: filter)
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Content
                if filteredAudioFiles.isEmpty {
                    EmptyStateView()
                } else {
                    List(filteredAudioFiles) { audioFile in
                        AudioFileRow(audioFile: audioFile) {
                            selectedAudioFile = audioFile
                            showingDetailView = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDetailView) {
                if let audioFile = selectedAudioFile {
                    AudioFileDetailView(audioFile: audioFile)
                }
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    private func loadMockData() {
        // Generate mock audio files for development
        audioFiles = generateMockAudioFiles()
    }
    
    private func getCount(for filter: ProcessingStatusFilter) -> Int {
        if filter == .all {
            return audioFiles.count
        }
        
        let status: AudioFile.ProcessingStatus
        switch filter {
        case .pending: status = .pending
        case .processing: status = .processing
        case .completed: status = .completed
        case .failed: status = .failed
        case .all: return audioFiles.count
        }
        
        return audioFiles.filter { $0.processingStatus == status }.count
    }
    
    private func generateMockAudioFiles() -> [AudioFile] {
        let mockFiles = [
            ("Team Standup Meeting", 1800, AudioFile.ProcessingStatus.completed),
            ("Client Call - Project Review", 2700, AudioFile.ProcessingStatus.completed),
            ("Interview with Candidate", 3600, AudioFile.ProcessingStatus.completed),
            ("Brainstorming Session", 1800, AudioFile.ProcessingStatus.processing),
            ("1-on-1 Performance Review", 1200, AudioFile.ProcessingStatus.pending),
            ("Product Demo Recording", 900, AudioFile.ProcessingStatus.failed)
        ]
        
        return mockFiles.enumerated().map { index, tuple in
            let name = tuple.0
            let duration = tuple.1
            let status = tuple.2
            
            let audioFile = AudioFile(
                fileName: name,
                fileURL: URL(string: "file://mock/\(index).m4a")!,
                duration: TimeInterval(duration),
                fileSize: Int64(duration * 1000), // Mock file size
                audioFormat: .m4a
            )
            
            var file = audioFile
            file.processingStatus = status
            
            // Add mock transcript and summary for completed files
            if status == AudioFile.ProcessingStatus.completed {
                file.transcript = createMockTranscript(for: file, mode: .basic)
                file.summary = createMockSummary(for: file, transcript: file.transcript!)
            }
            
            return file
        }
    }
    
    private func createMockTranscript(for audioFile: AudioFile, mode: Transcript.ProcessingMode) -> Transcript {
        let segments = [
            TranscriptSegment(startTime: 0, endTime: 30, text: "Welcome to our team meeting. Let's start with updates.", speaker: mode == .advanced ? "Speaker 1" : nil),
            TranscriptSegment(startTime: 30, endTime: 60, text: "I've completed the frontend implementation for the new feature.", speaker: mode == .advanced ? "Speaker 2" : nil),
            TranscriptSegment(startTime: 60, endTime: 90, text: "Great work! The backend API is also ready for testing.", speaker: mode == .advanced ? "Speaker 1" : nil)
        ]
        
        return Transcript(
            audioFileId: audioFile.id,
            processingMode: mode,
            segments: segments,
            confidence: 0.9
        )
    }
    
    private func createMockSummary(for audioFile: AudioFile, transcript: Transcript) -> Summary {
        let content = SummaryContent(
            title: "Meeting Summary",
            sections: [
                SummarySection(title: "Overview", content: "Team standup meeting with project updates", order: 1),
                SummarySection(title: "Key Points", content: "Frontend and backend implementation completed", order: 2)
            ],
            keyPoints: ["Frontend feature completed", "Backend API ready for testing"],
            actionItems: [ActionItem(description: "Begin testing phase")],
            participants: ["Team Member 1", "Team Member 2"],
            duration: audioFile.duration,
            date: audioFile.recordingDate
        )
        
        return Summary(
            transcriptId: transcript.id,
            audioFileId: audioFile.id,
            templateType: .teamMeeting,
            content: content,
            processingMode: transcript.processingMode
        )
    }
}

struct FilterPill: View {
    let filter: LibraryView.ProcessingStatusFilter
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(filter.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("(\(count))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? filter.color : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AudioFileRow: View {
    let audioFile: AudioFile
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(audioFile.processingStatus.color)
                        .frame(width: 12, height: 12)
                    
                    if audioFile.processingStatus == .processing {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 12, height: 12)
                    }
                }
                
                // File Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(audioFile.fileName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Text(audioFile.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(audioFile.formattedFileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(audioFile.audioFormat.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(audioFile.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Processing Status
                VStack(alignment: .trailing, spacing: 4) {
                    Text(audioFile.processingStatus.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(audioFile.processingStatus.color)
                    
                    if audioFile.processingStatus == .completed {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.caption)
                            Text("✓")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Recordings Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start recording audio or import files to see them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

#Preview {
    LibraryView()
}

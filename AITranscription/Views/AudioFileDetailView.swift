import SwiftUI

struct AudioFileDetailView: View {
    let audioFile: AudioFile
    @State private var selectedTab = 0
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Audio File Info
                VStack(spacing: 15) {
                    // File Icon and Status
                    HStack {
                        Image(systemName: "waveform")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(audioFile.fileName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            HStack {
                                Text(audioFile.processingStatus.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(audioFile.processingStatus.color.opacity(0.2))
                                    .foregroundColor(audioFile.processingStatus.color)
                                    .cornerRadius(8)
                                
                                Text(audioFile.formattedDuration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // File Details
                    HStack(spacing: 20) {
                        DetailItem(title: "Size", value: audioFile.formattedFileSize)
                        DetailItem(title: "Format", value: audioFile.audioFormat.displayName)
                        DetailItem(title: "Date", value: audioFile.formattedDate)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    Text("Summary").tag(0)
                    Text("Transcript").tag(1)
                    Text("Details").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Summary Tab
                    SummaryTabView(audioFile: audioFile)
                        .tag(0)
                    
                    // Transcript Tab
                    TranscriptTabView(audioFile: audioFile)
                        .tag(1)
                    
                    // Details Tab
                    DetailsTabView(audioFile: audioFile)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Action Buttons
                if audioFile.processingStatus == .completed {
                    VStack(spacing: 12) {
                        HStack(spacing: 15) {
                            Button(action: {
                                showingExportOptions = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        Text("Export as Word document, plain text, or PDF")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Audio Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    // Dismiss the view
                }
            )
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [audioFile.fileName])
        }
    }
}

struct DetailItem: View {
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

struct SummaryTabView: View {
    let audioFile: AudioFile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let summary = audioFile.summary {
                    SummaryContentView(summary: summary)
                } else {
                    EmptySummaryView()
                }
            }
            .padding()
        }
    }
}

struct SummaryContentView: View {
    let summary: Summary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Summary Header
            VStack(alignment: .leading, spacing: 8) {
                Text(summary.content.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Label(summary.content.formattedDate, systemImage: "calendar")
                    Spacer()
                    Label(summary.content.formattedDuration, systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Key Points
            if !summary.content.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Points")
                        .font(.headline)
                    
                    ForEach(summary.content.keyPoints, id: \.self) { point in
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                            Text(point)
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            // Action Items
            if !summary.content.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Action Items")
                        .font(.headline)
                    
                    ForEach(summary.content.actionItems) { item in
                        ActionItemRow(actionItem: item)
                    }
                }
            }
            
            // Sections
            ForEach(summary.content.sections.sorted(by: { $0.order < $1.order })) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.headline)
                    
                    Text(section.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Participants
            if !summary.content.participants.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.headline)
                    
                    ForEach(summary.content.participants, id: \.self) { participant in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text(participant)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
}

struct ActionItemRow: View {
    let actionItem: ActionItem
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(actionItem.status == .completed ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(actionItem.description)
                    .font(.subheadline)
                
                HStack {
                    if let assignee = actionItem.assignee {
                        Text("Assigned to: \(assignee)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(actionItem.priority.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(actionItem.priority.color).opacity(0.2))
                        .foregroundColor(Color(actionItem.priority.color))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EmptySummaryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Summary Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This audio file hasn't been processed yet or summary generation failed")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TranscriptTabView: View {
    let audioFile: AudioFile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let transcript = audioFile.transcript {
                    TranscriptContentView(transcript: transcript)
                } else {
                    EmptyTranscriptView()
                }
            }
            .padding()
        }
    }
}

struct TranscriptContentView: View {
    let transcript: Transcript
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Transcript Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Transcript")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Label(transcript.formattedDuration, systemImage: "clock")
                    Spacer()
                    Label("\(transcript.segments.count) segments", systemImage: "text.quote")
                    Spacer()
                    Label("\(Int(transcript.confidence * 100))% confidence", systemImage: "checkmark.shield")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Processing Mode
            HStack {
                Image(systemName: transcript.processingMode == .advanced ? "cloud" : "cpu")
                    .foregroundColor(transcript.processingMode == .advanced ? .blue : .green)
                Text(transcript.processingMode.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Transcript Segments
            ForEach(transcript.segments) { segment in
                TranscriptSegmentRow(segment: segment)
            }
        }
    }
}

struct TranscriptSegmentRow: View {
    let segment: TranscriptSegment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(segment.formattedStartTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                
                if let speaker = segment.speaker {
                    Text(speaker)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text("\(Int(segment.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(segment.text)
                .font(.subheadline)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EmptyTranscriptView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Transcript Available")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This audio file hasn't been transcribed yet or transcription failed")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DetailsTabView: View {
    let audioFile: AudioFile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // File Information
                VStack(alignment: .leading, spacing: 15) {
                    Text("File Information")
                        .font(.headline)
                    
                    DetailRow(title: "File Name", value: audioFile.fileName)
                    DetailRow(title: "File Size", value: audioFile.formattedFileSize)
                    DetailRow(title: "Duration", value: audioFile.formattedDuration)
                    DetailRow(title: "Format", value: audioFile.audioFormat.displayName)
                    DetailRow(title: "Recording Date", value: audioFile.formattedDate)
                    DetailRow(title: "Processing Status", value: audioFile.processingStatus.displayName)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Processing Information
                if let transcript = audioFile.transcript {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Processing Information")
                            .font(.headline)
                        
                        DetailRow(title: "Processing Mode", value: transcript.processingMode.displayName)
                        DetailRow(title: "Confidence Score", value: "\(Int(transcript.confidence * 100))%")
                        DetailRow(title: "Language", value: transcript.language.uppercased())
                        DetailRow(title: "Segments", value: "\(transcript.segments.count)")
                        DetailRow(title: "Speakers Detected", value: "\(transcript.speakerCount)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let mockAudioFile = AudioFile(
        fileName: "Sample Recording",
        fileURL: URL(string: "file://mock/sample.m4a")!,
        duration: 1800,
        fileSize: 5000000,
        audioFormat: .m4a
    )
    
    AudioFileDetailView(audioFile: mockAudioFile)
}

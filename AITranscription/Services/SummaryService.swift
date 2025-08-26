import Foundation
import Combine

class SummaryService: ObservableObject {
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0
    @Published var currentStatus = ""
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Generate summary based on transcript and template
    func generateSummary(
        for transcript: Transcript,
        template: SummaryTemplate,
        processingMode: Transcript.ProcessingMode
    ) async -> Summary? {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0
            currentStatus = "Starting summary generation..."
        }
        
        // Simulate summary generation steps
        await updateProgress(0.2, "Analyzing transcript content...")
        await updateProgress(0.4, "Identifying key points...")
        await updateProgress(0.6, "Extracting action items...")
        await updateProgress(0.8, "Formatting summary...")
        await updateProgress(1.0, "Summary complete!")
        
        // Generate summary content based on template
        let summaryContent = await generateSummaryContent(for: transcript, template: template)
        
        let summary = Summary(
            transcriptId: transcript.id,
            audioFileId: transcript.audioFileId,
            templateType: template,
            content: summaryContent,
            processingMode: processingMode
        )
        
        await MainActor.run {
            isGenerating = false
            generationProgress = 0
            currentStatus = ""
        }
        
        return summary
    }
    
    // Generate summary content based on template type
    private func generateSummaryContent(for transcript: Transcript, template: SummaryTemplate) async -> SummaryContent {
        let keyPoints = extractKeyPoints(from: transcript)
        let actionItems = extractActionItems(from: transcript)
        let participants = extractParticipants(from: transcript)
        
        let sections = generateTemplateSections(for: template, transcript: transcript)
        
        return SummaryContent(
            title: generateTitle(for: template, transcript: transcript),
            sections: sections,
            keyPoints: keyPoints,
            actionItems: actionItems,
            participants: participants,
            duration: transcript.duration,
            date: Date()
        )
    }
    
    // Generate template-specific sections
    private func generateTemplateSections(for template: SummaryTemplate, transcript: Transcript) -> [SummarySection] {
        switch template {
        case .oneOnOne:
            return [
                SummarySection(title: "Meeting Overview", content: "One-on-one meeting between participants", order: 1),
                SummarySection(title: "Key Discussion Points", content: extractDiscussionPoints(from: transcript), order: 2),
                SummarySection(title: "Action Items", content: formatActionItems(from: transcript), order: 3),
                SummarySection(title: "Follow-up Required", content: "Schedule next meeting and track action items", order: 4)
            ]
            
        case .teamMeeting:
            return [
                SummarySection(title: "Meeting Agenda", content: "Team standup and project updates", order: 1),
                SummarySection(title: "Topics Covered", content: extractDiscussionPoints(from: transcript), order: 2),
                SummarySection(title: "Decisions Made", content: extractDecisions(from: transcript), order: 3),
                SummarySection(title: "Action Items & Owners", content: formatActionItemsWithOwners(from: transcript), order: 4),
                SummarySection(title: "Next Steps", content: "Continue with action items and prepare for next meeting", order: 5)
            ]
            
        case .interview:
            return [
                SummarySection(title: "Candidate Background", content: "Interview for position", order: 1),
                SummarySection(title: "Key Questions & Answers", content: extractQAndA(from: transcript), order: 2),
                SummarySection(title: "Technical Assessment", content: extractTechnicalDetails(from: transcript), order: 3),
                SummarySection(title: "Recommendation", content: "Evaluate candidate based on interview performance", order: 4)
            ]
            
        case .brainstorming:
            return [
                SummarySection(title: "Session Objective", content: "Creative brainstorming session", order: 1),
                SummarySection(title: "Ideas Generated", content: extractIdeas(from: transcript), order: 2),
                SummarySection(title: "Top Concepts", content: extractTopConcepts(from: transcript), order: 3),
                SummarySection(title: "Implementation Feasibility", content: "Evaluate practical implementation of ideas", order: 4),
                SummarySection(title: "Next Actions", content: "Develop selected ideas and create action plan", order: 5)
            ]
            
        case .clientCall:
            return [
                SummarySection(title: "Call Purpose", content: "Client interaction and discussion", order: 1),
                SummarySection(title: "Client Needs", content: extractClientNeeds(from: transcript), order: 2),
                SummarySection(title: "Solutions Discussed", content: extractSolutions(from: transcript), order: 3),
                SummarySection(title: "Next Steps", content: "Follow up on discussed solutions and client requirements", order: 4)
            ]
            
        case .custom:
            return [
                SummarySection(title: "Custom Summary", content: "User-defined summary structure", order: 1),
                SummarySection(title: "Key Points", content: extractKeyPoints(from: transcript).joined(separator: "\n"), order: 2),
                SummarySection(title: "Notes", content: "Additional notes and observations", order: 3)
            ]
        }
    }
    
    // Extract key information from transcript
    private func extractKeyPoints(from transcript: Transcript) -> [String] {
        let sentences = transcript.fullText.components(separatedBy: ". ")
        let keySentences = sentences.prefix(5) // Top 5 sentences
        return Array(keySentences).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    private func extractActionItems(from transcript: Transcript) -> [ActionItem] {
        // Mock action items based on transcript content
        let mockActions = [
            "Follow up on discussed topics",
            "Schedule next meeting",
            "Review action items",
            "Send meeting notes to participants"
        ]
        
        return mockActions.map { ActionItem(description: $0) }
    }
    
    private func extractParticipants(from transcript: Transcript) -> [String] {
        if transcript.processingMode == .advanced {
            // Extract unique speakers from transcript
            let speakers = transcript.segments.compactMap { $0.speaker }
            return Array(Set(speakers)).sorted()
        } else {
            // Basic mode - no speaker detection
            return ["Participant 1", "Participant 2"]
        }
    }
    
    private func extractDiscussionPoints(from transcript: Transcript) -> String {
        let keyPoints = extractKeyPoints(from: transcript)
        return keyPoints.joined(separator: "\n• ")
    }
    
    private func extractDecisions(from transcript: Transcript) -> String {
        return "Decisions were made regarding the discussed topics. Review transcript for specific details."
    }
    
    private func formatActionItems(from transcript: Transcript) -> String {
        let actionItems = extractActionItems(from: transcript)
        return actionItems.map { "• \($0.description)" }.joined(separator: "\n")
    }
    
    private func formatActionItemsWithOwners(from transcript: Transcript) -> String {
        let actionItems = extractActionItems(from: transcript)
        return actionItems.map { "• \($0.description) - [Owner TBD]" }.joined(separator: "\n")
    }
    
    private func extractQAndA(from transcript: Transcript) -> String {
        return "Interview questions and candidate responses were discussed. Review transcript for specific details."
    }
    
    private func extractTechnicalDetails(from transcript: Transcript) -> String {
        return "Technical assessment and evaluation criteria were discussed during the interview."
    }
    
    private func extractIdeas(from transcript: Transcript) -> String {
        return "Various creative ideas and concepts were generated during the brainstorming session."
    }
    
    private func extractTopConcepts(from transcript: Transcript) -> String {
        return "Key concepts and innovative approaches were identified and prioritized."
    }
    
    private func extractClientNeeds(from transcript: Transcript) -> String {
        return "Client requirements and specific needs were discussed and documented."
    }
    
    private func extractSolutions(from transcript: Transcript) -> String {
        return "Potential solutions and approaches were explored to address client needs."
    }
    
    private func generateTitle(for template: SummaryTemplate, transcript: Transcript) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        switch template {
        case .oneOnOne:
            return "1-on-1 Meeting - \(dateFormatter.string(from: Date()))"
        case .teamMeeting:
            return "Team Meeting - \(dateFormatter.string(from: Date()))"
        case .interview:
            return "Interview Summary - \(dateFormatter.string(from: Date()))"
        case .brainstorming:
            return "Brainstorming Session - \(dateFormatter.string(from: Date()))"
        case .clientCall:
            return "Client Call Summary - \(dateFormatter.string(from: Date()))"
        case .custom:
            return "Meeting Summary - \(dateFormatter.string(from: Date()))"
        }
    }
    
    private func updateProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            generationProgress = progress
            currentStatus = status
        }
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: UInt64(0.3 * 1_000_000_000))
    }
    
    // Estimate generation time
    func estimateGenerationTime(for transcript: Transcript, template: SummaryTemplate) -> TimeInterval {
        let baseTime: TimeInterval = 30 // Base 30 seconds
        
        // Add time based on transcript length
        let lengthFactor = transcript.duration / 60 // Minutes
        let lengthTime = lengthFactor * 10 // 10 seconds per minute
        
        // Add time based on template complexity
        let templateTime: TimeInterval
        switch template {
        case .oneOnOne: templateTime = 15
        case .teamMeeting: templateTime = 25
        case .interview: templateTime = 30
        case .brainstorming: templateTime = 35
        case .clientCall: templateTime = 20
        case .custom: templateTime = 40
        }
        
        return baseTime + lengthTime + templateTime
    }
}

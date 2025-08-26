import Foundation

struct Summary: Identifiable, Codable {
    let id: UUID
    let transcriptId: UUID
    let audioFileId: UUID
    let createdAt: Date
    let templateType: SummaryTemplate
    let content: SummaryContent
    let processingMode: Transcript.ProcessingMode
    
    init(transcriptId: UUID, audioFileId: UUID, templateType: SummaryTemplate, content: SummaryContent, processingMode: Transcript.ProcessingMode) {
        self.id = UUID()
        self.transcriptId = transcriptId
        self.audioFileId = audioFileId
        self.createdAt = Date()
        self.templateType = templateType
        self.content = content
        self.processingMode = processingMode
    }
}

enum SummaryTemplate: String, Codable, CaseIterable {
    case oneOnOne = "one_on_one"
    case teamMeeting = "team_meeting"
    case interview = "interview"
    case brainstorming = "brainstorming"
    case clientCall = "client_call"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .oneOnOne: return "1-on-1 Meeting"
        case .teamMeeting: return "Team Meeting"
        case .interview: return "Interview"
        case .brainstorming: return "Brainstorming Session"
        case .clientCall: return "Client Call"
        case .custom: return "Custom Template"
        }
    }
    
    var icon: String {
        switch self {
        case .oneOnOne: return "person.2.fill"
        case .teamMeeting: return "person.3.fill"
        case .interview: return "person.badge.plus"
        case .brainstorming: return "lightbulb.fill"
        case .clientCall: return "phone.fill"
        case .custom: return "doc.text.fill"
        }
    }
    
    var description: String {
        switch self {
        case .oneOnOne: return "Perfect for individual meetings, performance reviews, and personal discussions"
        case .teamMeeting: return "Ideal for team standups, project updates, and group discussions"
        case .interview: return "Great for job interviews, candidate assessments, and hiring decisions"
        case .brainstorming: return "Best for creative sessions, idea generation, and innovation meetings"
        case .clientCall: return "Perfect for client meetings, sales calls, and customer interactions"
        case .custom: return "Create your own summary structure with custom sections"
        }
    }
}

struct SummaryContent: Codable {
    let title: String
    let sections: [SummarySection]
    let keyPoints: [String]
    let actionItems: [ActionItem]
    let participants: [String]
    let duration: TimeInterval
    let date: Date
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SummarySection: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let order: Int
    
    init(title: String, content: String, order: Int) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.order = order
    }
}

struct ActionItem: Identifiable, Codable {
    let id: UUID
    let description: String
    let assignee: String?
    let dueDate: Date?
    let priority: Priority
    let status: Status
    
    enum Priority: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            case .urgent: return "Urgent"
            }
        }
        
        var color: String {
            switch self {
            case .low: return "green"
            case .medium: return "blue"
            case .high: return "orange"
            case .urgent: return "red"
            }
        }
    }
    
    enum Status: String, Codable, CaseIterable {
        case pending = "pending"
        case inProgress = "in_progress"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
    }
    
    init(description: String, assignee: String? = nil, dueDate: Date? = nil, priority: Priority = .medium, status: Status = .pending) {
        self.id = UUID()
        self.description = description
        self.assignee = assignee
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
    }
}

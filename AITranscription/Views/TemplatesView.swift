import SwiftUI

struct TemplatesView: View {
    @State private var selectedTemplate: SummaryTemplate = .oneOnOne
    @State private var showingCustomTemplateBuilder = false
    @State private var customTemplates: [CustomTemplate] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Summary Templates")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose from pre-built templates or create your own")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Template Categories
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        // Pre-built Templates
                        ForEach(SummaryTemplate.allCases.filter { $0 != .custom }, id: \.self) { template in
                            TemplateDetailCard(
                                template: template,
                                isSelected: selectedTemplate == template
                            ) {
                                selectedTemplate = template
                            }
                        }
                        
                        // Custom Templates
                        ForEach(customTemplates, id: \.id) { customTemplate in
                            CustomTemplateCard(
                                customTemplate: customTemplate,
                                isSelected: selectedTemplate == .custom
                            ) {
                                selectedTemplate = .custom
                            }
                        }
                        
                        // Add Custom Template Button
                        AddCustomTemplateButton {
                            showingCustomTemplateBuilder = true
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Selected Template Preview
                if selectedTemplate != .custom {
                    TemplatePreviewView(template: selectedTemplate)
                } else if let customTemplate = customTemplates.first {
                    CustomTemplatePreviewView(customTemplate: customTemplate)
                }
            }
            .padding()
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCustomTemplateBuilder) {
                CustomTemplateBuilderView { customTemplate in
                    customTemplates.append(customTemplate)
                    showingCustomTemplateBuilder = false
                }
            }
        }
    }
}

struct TemplateDetailCard: View {
    let template: SummaryTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(template.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Template Features
                VStack(spacing: 4) {
                    ForEach(getTemplateFeatures(for: template), id: \.self) { feature in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(isSelected ? .white : .green)
                            Text(feature)
                                .font(.caption2)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getTemplateFeatures(for template: SummaryTemplate) -> [String] {
        switch template {
        case .oneOnOne:
            return ["Key discussion points", "Action items", "Follow-up tracking"]
        case .teamMeeting:
            return ["Agenda coverage", "Decisions made", "Action items & owners"]
        case .interview:
            return ["Q&A summary", "Technical assessment", "Recommendations"]
        case .brainstorming:
            return ["Ideas generated", "Top concepts", "Implementation plan"]
        case .clientCall:
            return ["Client needs", "Solutions discussed", "Next steps"]
        case .custom:
            return ["Custom sections", "Flexible structure", "Personal branding"]
        }
    }
}

struct CustomTemplateCard: View {
    let customTemplate: CustomTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .purple)
                
                Text(customTemplate.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                
                Text("\(customTemplate.sections.count) custom sections")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                
                // Custom sections preview
                VStack(spacing: 4) {
                    ForEach(customTemplate.sections.prefix(3), id: \.id) { section in
                        HStack {
                            Image(systemName: "square.fill")
                                .font(.caption2)
                                .foregroundColor(isSelected ? .white : .purple)
                            Text(section.title)
                                .font(.caption2)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    if customTemplate.sections.count > 3 {
                        Text("+\(customTemplate.sections.count - 3) more")
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white.opacity(0.6) : .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddCustomTemplateButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.purple)
                
                Text("Create Custom")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Text("Build your own template")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TemplatePreviewView: View {
    let template: SummaryTemplate
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Template Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(getTemplateSections(for: template), id: \.self) { section in
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text(section)
                            .font(.subheadline)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private func getTemplateSections(for template: SummaryTemplate) -> [String] {
        switch template {
        case .oneOnOne:
            return ["Meeting Overview", "Key Discussion Points", "Action Items", "Follow-up Required"]
        case .teamMeeting:
            return ["Meeting Agenda", "Topics Covered", "Decisions Made", "Action Items & Owners", "Next Steps"]
        case .interview:
            return ["Candidate Background", "Key Questions & Answers", "Technical Assessment", "Recommendation"]
        case .brainstorming:
            return ["Session Objective", "Ideas Generated", "Top Concepts", "Implementation Feasibility", "Next Actions"]
        case .clientCall:
            return ["Call Purpose", "Client Needs", "Solutions Discussed", "Next Steps"]
        case .custom:
            return ["Custom sections will be defined by user"]
        }
    }
}

// MARK: - Custom Template Models
struct CustomTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let sections: [CustomSection]
    let createdAt: Date
    
    init(name: String, description: String, sections: [CustomSection]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.sections = sections
        self.createdAt = Date()
    }
}

struct CustomSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let type: SectionType
    let order: Int
    
    init(title: String, type: SectionType, order: Int) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.order = order
    }
    
    enum SectionType: String, Codable, CaseIterable {
        case text = "text"
        case bulletPoints = "bullet_points"
        case table = "table"
        case checkbox = "checkbox"
        case customPrompt = "custom_prompt"
        
        var displayName: String {
            switch self {
            case .text: return "Text Field"
            case .bulletPoints: return "Bullet Points"
            case .table: return "Table"
            case .checkbox: return "Checkbox List"
            case .customPrompt: return "Custom Prompt"
            }
        }
    }
}

#Preview {
    TemplatesView()
}

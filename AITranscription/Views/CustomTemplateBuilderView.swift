import SwiftUI

struct CustomTemplateBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var templateName = ""
    @State private var templateDescription = ""
    @State private var sections: [CustomSection] = []
    @State private var showingAddSection = false
    
    let onTemplateCreated: (CustomTemplate) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    Text("Create Custom Template")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Build a personalized summary template")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Template Details
                Form {
                    Section("Template Information") {
                        TextField("Template Name", text: $templateName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Description", text: $templateDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    Section("Sections") {
                        if sections.isEmpty {
                            Text("No sections added yet")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(sections.indices, id: \.self) { index in
                                SectionRow(
                                    section: sections[index],
                                    onDelete: {
                                        sections.remove(at: index)
                                    }
                                )
                            }
                            .onMove { from, to in
                                sections.move(fromOffsets: from, toOffset: to)
                                updateSectionOrder()
                            }
                        }
                        
                        Button(action: {
                            showingAddSection = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Section")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Create Button
                VStack {
                    Button(action: createTemplate) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Create Template")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCreateTemplate ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canCreateTemplate)
                    
                    Text("Template will be saved and available for future use")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Custom Template")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }
            )
        }
        .sheet(isPresented: $showingAddSection) {
            AddSectionView { section in
                sections.append(section)
                updateSectionOrder()
            }
        }
    }
    
    private var canCreateTemplate: Bool {
        !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !sections.isEmpty
    }
    
    private func updateSectionOrder() {
        for (index, section) in sections.enumerated() {
            sections[index] = CustomSection(
                title: section.title,
                type: section.type,
                order: index
            )
        }
    }
    
    private func createTemplate() {
        let customTemplate = CustomTemplate(
            name: templateName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: templateDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            sections: sections
        )
        
        onTemplateCreated(customTemplate)
    }
}

struct SectionRow: View {
    let section: CustomSection
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(section.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sectionTitle = ""
    @State private var selectedType: CustomSection.SectionType = .text
    
    let onSectionAdded: (CustomSection) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Section Details") {
                    TextField("Section Title", text: $sectionTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Section Type", selection: $selectedType) {
                        ForEach(CustomSection.SectionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SinglePickerStyle())
                }
                
                Section("Section Type Description") {
                    Text(getTypeDescription(for: selectedType))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Section")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    addSection()
                }
                .disabled(sectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func getTypeDescription(for type: CustomSection.SectionType) -> String {
        switch type {
        case .text:
            return "A simple text field for general content and notes"
        case .bulletPoints:
            return "A list of bullet points for key items and takeaways"
        case .table:
            return "A structured table for organized data and comparisons"
        case .checkbox:
            return "A checklist for action items and completion tracking"
        case .customPrompt:
            return "A custom AI prompt for specific content generation"
        }
    }
    
    private func addSection() {
        let section = CustomSection(
            title: sectionTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            type: selectedType,
            order: 0
        )
        
        onSectionAdded(section)
        dismiss()
    }
}

#Preview {
    CustomTemplateBuilderView { _ in }
}

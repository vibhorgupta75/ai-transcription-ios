import SwiftUI

struct CustomTemplatePreviewView: View {
    let customTemplate: CustomTemplate
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Custom Template Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(customTemplate.sections.sorted(by: { $0.order < $1.order }), id: \.id) { section in
                    HStack {
                        Image(systemName: "square.fill")
                            .foregroundColor(.purple)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(section.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(section.type.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Template Info
            VStack(spacing: 8) {
                Text("Template: \(customTemplate.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Created: \(customTemplate.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

#Preview {
    let mockCustomTemplate = CustomTemplate(
        name: "My Custom Template",
        description: "A custom template for my specific needs",
        sections: [
            CustomSection(title: "Introduction", type: .text, order: 0),
            CustomSection(title: "Key Points", type: .bulletPoints, order: 1),
            CustomSection(title: "Action Items", type: .checkbox, order: 2)
        ]
    )
    
    CustomTemplatePreviewView(customTemplate: mockCustomTemplate)
}

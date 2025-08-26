import SwiftUI

struct TemplateSelectionView: View {
    @Binding var selectedTemplate: SummaryTemplate
    let onTemplateSelected: (SummaryTemplate) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Choose Summary Template")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select the template that best fits your meeting type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Template Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(SummaryTemplate.allCases, id: \.self) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate == template
                        ) {
                            selectedTemplate = template
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    onTemplateSelected(selectedTemplate)
                }) {
                    HStack {
                        Text("Continue with \(selectedTemplate.displayName)")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

struct TemplateCard: View {
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
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TemplateSelectionView(
        selectedTemplate: .constant(.oneOnOne),
        onTemplateSelected: { _ in }
    )
}

import SwiftUI

struct SettingsView: View {
    @AppStorage("processingMode") private var defaultProcessingMode: String = Transcript.ProcessingMode.basic.rawValue
    @AppStorage("defaultTemplate") private var defaultTemplate: String = SummaryTemplate.oneOnOne.rawValue
    @AppStorage("autoExport") private var autoExport = false
    @AppStorage("exportFormat") private var exportFormat: String = "word"
    @AppStorage("cloudProcessingEnabled") private var cloudProcessingEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var showingExportOptions = false
    @State private var showingCloudSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // General Settings
                Section("General") {
                    // Default Processing Mode
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default Processing Mode")
                                .font(.subheadline)
                            Text("Choose how audio is processed by default")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Processing Mode", selection: $defaultProcessingMode) {
                            ForEach(Transcript.ProcessingMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode.rawValue)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Default Template
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default Summary Template")
                                .font(.subheadline)
                            Text("Template used for new summaries")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Template", selection: $defaultTemplate) {
                            ForEach(SummaryTemplate.allCases, id: \.self) { template in
                                Text(template.displayName).tag(template.rawValue)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Export Settings
                Section("Export & Sharing") {
                    // Export Format
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Export Format")
                                .font(.subheadline)
                            Text("Default format for exported documents")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Format", selection: $exportFormat) {
                            Text("Word Document").tag("word")
                            Text("Plain Text").tag("text")
                            Text("PDF").tag("pdf")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // Auto Export
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto Export")
                                .font(.subheadline)
                            Text("Automatically export completed summaries")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $autoExport)
                    }
                    
                    // Export Options Button
                    Button(action: {
                        showingExportOptions = true
                    }) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Advanced Export Options")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Cloud Processing
                Section("Cloud Processing") {
                    // Cloud Processing Toggle
                    HStack {
                        Image(systemName: "cloud")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Cloud Processing")
                                .font(.subheadline)
                            Text("Allow advanced processing in the cloud")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $cloudProcessingEnabled)
                    }
                    
                    if cloudProcessingEnabled {
                        // Cloud Settings Button
                        Button(action: {
                            showingCloudSettings = true
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                
                                Text("Cloud Settings")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Usage Statistics
                        HStack {
                            Image(systemName: "chart.bar")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Monthly Usage")
                                    .font(.subheadline)
                                Text("0 minutes processed this month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Notifications
                Section("Notifications") {
                    // Notifications Toggle
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Push Notifications")
                                .font(.subheadline)
                            Text("Get notified when processing is complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                    }
                }
                
                // App Information
                Section("App Information") {
                    // Version
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    // About Button
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("About")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView()
        }
        .sheet(isPresented: $showingCloudSettings) {
            CloudSettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("exportFormat") private var exportFormat: String = "word"
    @AppStorage("includeTimestamps") private var includeTimestamps = true
    @AppStorage("includeSpeakerLabels") private var includeSpeakerLabels = true
    @AppStorage("includeConfidence") private var includeConfidence = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Document Format") {
                    Picker("Export Format", selection: $exportFormat) {
                        Text("Word Document (.docx)").tag("word")
                        Text("Plain Text (.txt)").tag("text")
                        Text("PDF (.pdf)").tag("pdf")
                        Text("Markdown (.md)").tag("markdown")
                    }
                                            .pickerStyle(MenuPickerStyle())
                }
                
                Section("Transcript Options") {
                    Toggle("Include Timestamps", isOn: $includeTimestamps)
                    Toggle("Include Speaker Labels", isOn: $includeSpeakerLabels)
                    Toggle("Include Confidence Scores", isOn: $includeConfidence)
                }
                
                Section("Summary Options") {
                    Toggle("Include Action Items", isOn: .constant(true))
                    Toggle("Include Key Points", isOn: .constant(true))
                    Toggle("Include Participants", isOn: .constant(true))
                }
                
                Section("File Naming") {
                    Text("Format: [Date]_[Time]_[Template]_Summary")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

struct CloudSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("openaiApiKey") private var openaiApiKey = ""
    @AppStorage("maxFileSize") private var maxFileSize = 100.0
    @AppStorage("autoProcessLongFiles") private var autoProcessLongFiles = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Configuration") {
                    SecureField("OpenAI API Key", text: $openaiApiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Your API key is stored securely on your device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Processing Limits") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maximum File Size: \(Int(maxFileSize)) MB")
                        
                        Slider(value: $maxFileSize, in: 10...500, step: 10)
                    }
                    
                    Toggle("Auto-process Long Files", isOn: $autoProcessLongFiles)
                    
                    Text("Files longer than 15 minutes will automatically use cloud processing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Cost Management") {
                    HStack {
                        Text("Estimated Monthly Cost")
                        Spacer()
                        Text("$0.00")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Based on 0 minutes of processing this month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Cloud Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Icon
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // App Info
                VStack(spacing: 10) {
                    Text("AI Transcription")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Transform your audio into intelligent meeting summaries")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "mic.fill", title: "High-Quality Recording", description: "Record audio directly in the app or import existing files")
                    
                    FeatureRow(icon: "cpu", title: "Local Processing", description: "Free transcription using on-device AI processing")
                    
                    FeatureRow(icon: "cloud", title: "Cloud Enhancement", description: "Optional cloud processing for professional results")
                    
                    FeatureRow(icon: "doc.text.fill", title: "Smart Templates", description: "Pre-built and custom summary templates")
                    
                    FeatureRow(icon: "person.2.fill", title: "Speaker Detection", description: "Identify and label different speakers automatically")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Built with SwiftUI and CoreML")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("© 2024 AI Transcription")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}

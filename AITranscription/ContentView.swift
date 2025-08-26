import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordingView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Record")
                }
            
            LibraryView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Library")
                }
            
            TemplatesView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Templates")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}

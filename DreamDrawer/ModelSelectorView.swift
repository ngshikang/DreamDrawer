import SwiftUI

struct ModelSelectorView: View {
    
    let resources: [String]
    @State var selectedResource: String = ""
    @Binding var url: URL?
    @Binding var selectedModel: String

    var body: some View {
        HStack {
            Text("Select Model: ")
            Picker("Select Resource", selection: $selectedResource) {
                ForEach(resources, id: \.self) { resource in
                    Text(resource)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedResource) {
                updateSelectedResource(selectedResource)
            }
        }
        .onAppear {
            if selectedResource != "" {
                updateSelectedResource(selectedResource)
            } else if let firstResource = resources.first {
                selectedResource = firstResource
                updateSelectedResource(firstResource)
            }
        }
    }
    
    private func updateSelectedResource(_ newValue: String) {
        if newValue != "" {
            let resourceString = newValue
            print(resourceString)
            guard let path = Bundle.main.path(forResource: resourceString, ofType: nil) else {
                fatalError("Fatal error: failed to find the CoreML models.")
            }
            let resourceURL = URL(fileURLWithPath: path)
            self.url = resourceURL
            
            print("selected resource")
            print(path)
            
            if let validURL = url {
                selectedModel = validURL.lastPathComponent

            } else {
                print("model not found")
            }
        }
    }
}

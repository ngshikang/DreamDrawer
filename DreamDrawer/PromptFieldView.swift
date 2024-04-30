import SwiftUI

struct PromptFieldView: View {
    @Binding var posPrompt: String
    @Binding var negPrompt: String
    
    var body: some View{
        HStack {
            TextField("Positive Prompt", text: $posPrompt, axis: .vertical)
                .padding(12)
                .background(Color.green.opacity(0.3).cornerRadius(10))
            
            Button(action: {
                self.posPrompt = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
            
        }
        .padding()
        HStack{
            TextField("Negative Prompt", text: $negPrompt, axis: .vertical)
                .padding(12)
                .background(Color.red.opacity(0.3).cornerRadius(10))
            
            Button(action: {
                self.negPrompt = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                
            }
        }
        .padding()
    }
    
}

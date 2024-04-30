import SwiftUI

struct IterationsSelectorView: View {
    @Binding var iterations: Int
    @State var iterationString: String
    
    var body: some View{
        HStack{
            Text("Iterations: ")
            TextField("\(iterations)", text: $iterationString)
                .keyboardType(.numberPad)
                .onChange(of: iterationString){
                    if let validNumber = Int(iterationString) {
                        iterations = validNumber
                    }
                }
        }
        
    }
}

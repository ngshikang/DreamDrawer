import SwiftUI

struct GuidanceSelectorView: View{
    @Binding var guidanceScale: Float
    
    var body: some View {
        HStack{
            Text("Guidance: ")
            Slider(value: $guidanceScale, in: 0...15, step: 0.1)
            Text("\(guidanceScale, specifier: "%.1f")")
        }
    }
}

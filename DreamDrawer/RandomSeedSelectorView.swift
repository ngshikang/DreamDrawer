import SwiftUI

struct RandomSeedSelectorView: View {
    @Binding var randomSeed: UInt32
    
    @State var seedString: String
    var body: some View{
        HStack{
            
            Button(action :{
                randomSeed = UInt32.random(in: 0..<UInt32.max)
                seedString = String(randomSeed)
            }){
                Text("Seed: ")
            }
            
            TextField(String(randomSeed), text: $seedString)
                .keyboardType(.numberPad)
                .onChange(of: seedString) {
                    if let validNumber = UInt32(seedString) {
                        randomSeed = validNumber
                    }
                    
                }
        }
        .padding()
    }
}

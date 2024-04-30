import SwiftUI

struct StyleSelectorView: View {
    let styles: ReadData
    
    @Binding var selectedStyleIndex: Int
    @Binding var posStyle: String
    @Binding var negStyle: String
    @Binding var styleName: String
    var body: some View{
        HStack{
            Text("Select a style: ")
            Picker("Select a Style", selection: $selectedStyleIndex) {
                ForEach(0..<styles.styles.count, id: \.self) { index in
                    Text(styles.styles[index].name).tag(index)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .onChange(of: selectedStyleIndex){
                posStyle = styles.styles[selectedStyleIndex].prompt
                negStyle = styles.styles[selectedStyleIndex].negative_prompt
                styleName = styles.styles[selectedStyleIndex].name
            }
        }
        
    }
}

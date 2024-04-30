import SwiftUI

struct Background: View {
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width
            
            Rectangle()
                .fill(Color.brown)
                .frame(width: w, height: h)
        }
        
    }
}

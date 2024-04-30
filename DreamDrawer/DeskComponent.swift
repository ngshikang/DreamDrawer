import SwiftUI
import UIKit
import MobileCoreServices
import PhotosUI
import CoreML
import StableDiffusion

let paperWidth: CGFloat = 1/2
let paperHeight: CGFloat = 0.2
let paperPositionX: CGFloat = 1/2
let paperPositionY: CGFloat = 0.18
let paperColor = Color(red: 0.9, green: 0.875, blue: 0.8)

let deskEdge: CGFloat = 0.32
let deskColor = Color.white


struct Desk: View {
    @Binding var posPrompt: String
    @Binding var showPopup: Bool
    var body: some View {
        
        
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width

            Text(posPrompt)
                    .frame(width: w, height: h*paperHeight)
                    .foregroundColor(.black)
                    .font(.custom("Inter", size: 21))
                    .fontDesign(.serif)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .multilineTextAlignment(.leading)
                    .position(x:w/2, y:h*deskEdge/2)
                    .onTapGesture {
                        showPopup = true
                    }
        }
    }
}

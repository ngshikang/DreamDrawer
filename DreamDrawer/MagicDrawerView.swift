import SwiftUI
import UIKit
import MobileCoreServices
import PhotosUI
import CoreML
import StableDiffusion

let drawerWidth: CGFloat = 5/6
let drawerPadding = 0.2
let drawerBottom = 0.8
let drawerHeight: CGFloat = drawerBottom - deskEdge + drawerPadding

struct MagicDrawer: View {
    @EnvironmentObject var dataModel: DataModel
    @Environment(\.dismiss) var dismiss
    let parent: ContentView

    @Binding var generatingImage: Bool
    @Binding var generatedImage: CGImage?
    @Binding var generationTime: Double?
    @Binding var posPrompt: String

    var body: some View {
        
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width

            VStack {
                if let generatedImage = generatedImage, let generationTime = generationTime {
                    let imageToShow = UIImage(cgImage: generatedImage)
                    let image = Image(uiImage: imageToShow)
                    
                    VStack {
                        Text("Generated in \(generationTime, specifier: "%.2f") seconds")
                            .padding()
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()

                    }
                }

                Button(action: {
                    generatingImage.toggle()
                }) {
                    if generatingImage {
                                    HStack {
                                        ProgressView() // This adds the spinner
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Generating...")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                } else {
                                    Text("Generate Image")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }	
                }
                if generatedImage != nil{
                    let imageToShow = UIImage(cgImage: generatedImage!)
                    
                        Button("Save Image") {
                            guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TempImage.png") else {
                                return
                            }

                            let pngData = imageToShow.pngData();
                            do {
                                try pngData?.write(to: imageURL);
                                dataModel.addItem(Item(url:imageURL, pos:posPrompt))
                                self.parent.dismiss()
                            } catch { }
                            
                        }.padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .frame(width: w, height: h)
        }
    }
}

import SwiftUI
import UIKit
import MobileCoreServices
import PhotosUI
import CoreML
import StableDiffusion

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UnitPoint {
    static var random: UnitPoint {
        UnitPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContext(targetSize)
    image.draw(in: CGRect(origin: .zero, size: targetSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        })
    }
}

struct DismissKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}


struct Style: Codable, Identifiable, Hashable {
    enum CodingKeys: CodingKey {
        case name
        case prompt
        case negative_prompt
    }
    
    var id = UUID()
    var name: String
    var prompt: String
    var negative_prompt: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


class ReadData: ObservableObject  {
    @Published var styles = [Style]()
    
    init(){
        loadData()
    }
    
    func loadData()  {
        guard let url = Bundle.main.url(forResource: "styles", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        let data = try? Data(contentsOf: url)
        let styles = try? JSONDecoder().decode([Style].self, from: data!)
        self.styles = styles!
    }
}


struct CustomLabelView: View {
    var body: some View {
        // Create a Text view with the desired attributes
        Text("Hello.")
            .font(Font.custom("Inter-Bold", size: 44))  // Set custom font and size
            .kerning(-0.32)  // Set character spacing
            .foregroundColor(Color.black)  // Set text color
            .lineSpacing(21 * 0.39)  // Set line spacing based on your original code
            .frame(width: 149, height: 38)  // Set frame size
            .padding(.leading, 26)  // Add leading padding
            .padding(.top, 109)  // Add top padding
    }
}

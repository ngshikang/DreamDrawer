//
//  ContentView.swift
//
//  Created by David Wang on 2024-04-01.
//

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

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContext(targetSize)
    image.draw(in: CGRect(origin: .zero, size: targetSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
}


               
struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {

            // 2
            configuration.isOn.toggle()

        }, label: {
            HStack {
                // 3
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

let paperWidth: CGFloat = 1/3 // of width
let paperHeight: CGFloat = 0.2 //of height

let paperPositionX: CGFloat = 1/3
let paperPositionY: CGFloat = 0.18


let deskEdge: CGFloat = 0.32 // percentage of the screen taken up by desk
let drawerSidebar: CGFloat = 0.015 // width of drawer side bars
let drawerKnob: CGFloat = 0.035 // size of the drawer handle
let drawerWidth: CGFloat = 7/8 // width of drawer
let drawerPadding = 0.2 // length of drawer covered by desk when open
let drawerBottom = 0.85 // percentage of screen that the open drawer extends until
let drawerHeight: CGFloat = drawerBottom - deskEdge + drawerPadding


//let floorColor = Color(red: 0.7, green: 0.37, blue: 0.11)
let floorColor = Color(red: 0.0, green: 0.0, blue: 0.0)
let paperColor = Color(red: 0.9, green: 0.875, blue: 0.8)
let drawerColor = Color(red: 0.52, green: 0.89, blue:0.89)
let drawerSideColor = Color(red:0.36, green:0.24 , blue:0.2)
let deskColor = Color.brown

let drawerClosedRatio: CGFloat = deskEdge - drawerHeight + 0.04 // position of the top of the drawer when closed
let drawerOpenRatio: CGFloat = drawerBottom - drawerHeight // position of the top of the drawer when open
let drawerContentRatio: CGFloat = drawerOpenRatio - drawerClosedRatio // length of the part of the drawer that can be seen when open

struct MagicDrawer: View {
    
    @Binding var generatingImage: Bool
    @Binding var generatedImage: CGImage?
    @Binding var generationTime: Double?
    var prompt: String
    @State private var drawerPositionRatio: CGFloat = drawerClosedRatio + 0.1
    @State private var currentDragAmount: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width
            
            ZStack{
                AuroraView()
                    .overlay(
                        Rectangle().frame(width: h*drawerSidebar).foregroundColor(drawerSideColor), alignment: .leading
                    )
                    .overlay(
                        Rectangle().frame(width: h*drawerSidebar).foregroundColor(drawerSideColor), alignment: .trailing
                    )
                    .overlay(
                        Rectangle().frame(height: h*drawerSidebar).foregroundColor(drawerSideColor), alignment: .bottom
                    )
                    
                    .frame(width: w * drawerWidth, height: h * drawerHeight)
                    .clipShape(Rectangle())
                    .overlay(
                        Circle().frame(height: h*drawerKnob).foregroundColor(drawerSideColor).offset(y: h*(drawerKnob+drawerSidebar)/2), alignment: .bottom
                    )
                    .offset(x: w * (1-drawerWidth)/2, y: h * self.drawerPositionRatio)
                    .onAppear{
                        self.drawerPositionRatio = drawerClosedRatio
                    }
//                if generatingImage {
//          
//                    VStack{
//                        Spacer()
//                        HStack{
//
//                            Text("generating image, first time may be slow ...")
//                                .foregroundColor(.white)
//                                .padding()
//                        }
//                    }
//                    .frame(width: w * drawerWidth, height: h * drawerHeight)
//                    .offset(x: w * (1-drawerWidth)/2, y: h * (drawerPadding/2)) // origin is the top of the drawer
//                    
//                }
                
                if self.drawerPositionRatio == drawerOpenRatio {
                    
                   if let generatedImage = generatedImage, let generationTime = generationTime {

                       let imageToShow = UIImage(cgImage: generatedImage)
                       let image = Image(uiImage: imageToShow)
                       VStack {
                           image
                               .resizable()
                               .aspectRatio(1, contentMode: .fit)
                               .padding()
                           Text("\(generationTime)s!")
                           ShareLink(item: image, preview: SharePreview("\(prompt)", image: image)){
                               Label("", systemImage: "square.and.arrow.up")
                                   .labelStyle(.iconOnly)
                                   .padding()
                           }
                               .foregroundColor(.black)
//                               .background(Color.blue)
//                               .cornerRadius(20)
                       }
                       .frame(width: w * drawerWidth, height: h * drawerHeight)
                       .offset(x: w * (1-drawerWidth)/2, y: h * (drawerPadding)) // origin is the top of the drawer
                    }
                }

            }
            
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.currentDragAmount = value.translation.height / geometry.size.height
                        
                    }
                    .onEnded { value in
                        // Adjust the rectangle height based on the drag direction
                        print("current drag amount \(currentDragAmount)")

                            if self.drawerPositionRatio == drawerClosedRatio && currentDragAmount > 0.01 {
                                    self.drawerPositionRatio = drawerOpenRatio
                                    generatingImage = true
                                    print("generating image set to true")
                                
                            } else if currentDragAmount < -0.01 {
                                    self.drawerPositionRatio = drawerClosedRatio
                                
                            }
                            self.currentDragAmount = 0.0
                    }
            )
            .disabled(generatingImage)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0.0),
                value: drawerPositionRatio
            )
        }
    }
}

struct Background: View {
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width
            
            Rectangle()
                .fill(floorColor)
                .frame(width: w, height: h)
        }
        
    }
}

struct Desk: View {
    @Binding var posPrompt: String
    @Binding var showPopup: Bool
    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width
            
            ZStack{
                Rectangle()
                    .fill(ImagePaint(image: Image("desk_texture"), scale:0.6))
                    .frame(width: w, height: h*deskEdge)
                    .position(x:w/2, y:h*deskEdge/2)
                Rectangle()
                    .fill(deskColor)
                    .frame(width: w, height: h*deskEdge)
                    .position(x:w/2, y:h*deskEdge/2)
                    .opacity(0.9)
                Text(posPrompt)
                    .frame(width: w*paperWidth, height: h*paperHeight)
                    .foregroundColor(.black)
                    .font(.custom("Zapfino", size: 12))
                    .padding() // Add some internal padding if needed
                    .background(paperColor) // Set the background color of the text frame
                    .cornerRadius(10)
                    .position(x: w * paperPositionX, y: h*paperPositionY)
                    .onTapGesture {
                        // Show the pop-up when the rectangle is tapped
                        showPopup = true
                    }
            }
        }
        
    }
}

struct DeskShadow: View {

    var body: some View {
        GeometryReader { geometry in
            let h = geometry.size.height
            let w = geometry.size.width
            
            ZStack{
                Rectangle()
                    .fill(deskColor)
                    .frame(width: w, height: h*(deskEdge*1.05))
                    .position(x:w/2, y:h*deskEdge/2)
                    .opacity(0.8)
               
            }
        }
        
    }
}


struct ContentView: View {
    
    @State private var isPickerPresented: Bool = false
    @State var styleName: String = ""
    @State var posPrompt: String = "A cute golden retreiver in the style of van gogh"
    @State var posStyle: String = "{prompt}"
    @State var negPrompt: String = ""
    @State var negStyle: String = ""
    
    @State var randomSeed: UInt32 = UInt32.random(in: 1..<UInt32.max)
    @State var seedString: String = ""
    @State var iterationString: String = ""
    @State var iterations: Int = 4
    @State var guidanceScale: Float = 1.0
    @State var prevGenConfig = StableDiffusionPipeline.Configuration(prompt: "(#(#($##$@#$") // some dummy config
    
    @State private var generatingImage: Bool = false
    @State var showAlert = false
    
    @State var modelDisplayText: String = "Select Model"
    let resources = ["tiny_abs_lcm"]
    @State var selectedModel: String = ""
    
    @State private var url: URL? = nil
    
    
    @State private var selectedStyleIndex = 0
    @ObservedObject var styles = ReadData()
    
    @StateObject var pipelineInterface = PipelineInterface()
    
    @State var generatedImage: CGImage? = nil
    @State var generationTime: TimeInterval? = nil
    
    func addStyle(posPrompt: String, posStyle: String, negPrompt: String, negStyle: String) -> (String, String){
        print()
        var styledPosPrompt = posStyle
        var styledNegPrompt = ""
        
        print("selectedStyleIndex \(selectedStyleIndex)")
        if let posStyleRange = styles.styles[selectedStyleIndex].prompt.range(of: "{prompt}") {
            print("pos prompt \(posPrompt), posStyleRange: \(posStyleRange)")
            styledPosPrompt.replaceSubrange(posStyleRange, with: posPrompt)
        } else{
            styledPosPrompt = posPrompt
        }
        
        styledNegPrompt = negPrompt + negStyle
        
        return (styledPosPrompt, styledNegPrompt)
    }
    
    @State private var currentDragAmount: CGFloat = 0.0
    
    @State private var startPoint = UnitPoint.random
    @State private var endPoint = UnitPoint.random
    
    // Define your gradient colors
    let gradientColors = Gradient(colors: [
            Color(red: 0.101, green: 0.737, blue: 0.611),
            Color(red: 0.125, green: 0.698, blue: 0.667),
            Color(red: 0.482, green: 0.800, blue: 0.442),
            Color(red: 0.663, green: 0.557, blue: 0.827),
            Color(red: 0.737, green: 0.561, blue: 0.561),
            Color(red: 0.556, green: 0.266, blue: 0.678)
        ])
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var isExpanded = false
    @State private var showPopup = false
        var body: some View {
            GeometryReader { geometry in
                let h = geometry.size.height
                let w = geometry.size.width
                
                ZStack(alignment: .top){
                    // background
                    
                    StarryBackground()
//                    DeskShadow()
                    MagicDrawer(generatingImage: $generatingImage, generatedImage: $generatedImage, generationTime: $generationTime, prompt: posPrompt)
                        .onChange(of: generatingImage){
                            Task{
                                if generatingImage == true { //only generate if the change of generatingImage was from false to true
                                    
                                    let (posPromptStyled, negPromptStyled) = addStyle(posPrompt: posPrompt, posStyle: posStyle, negPrompt: negPrompt, negStyle: negStyle)
                                    
                                    print("pos prompt: \(posPromptStyled)")
                                    print("neg prompt: \(negPromptStyled)")
                                    
                                    var genConfig = StableDiffusionPipeline.Configuration(prompt: posPromptStyled)
                                    genConfig.negativePrompt = negPromptStyled
                                    
                                    genConfig.stepCount = iterations
                                    genConfig.seed = randomSeed
                                    genConfig.guidanceScale = guidanceScale
                                    genConfig.disableSafety = true
                                    genConfig.schedulerType = StableDiffusionScheduler.lcmScheduler
                                    genConfig.useDenoisedIntermediates = true
                                    
                                    if let modelUrl = url {
                                        if genConfig != prevGenConfig{
                                            print("generating image")
                                            generatedImage = nil // remove the previous image
//                                            print("step count: \(iterations)")
                                            pipelineInterface.initModel(modelURL: modelUrl)
                                            
//                                            generatedImage = UIImage(named:"dog")?.cgImage
//                                            generationTime = -0.9999
                                            
                                            (generatedImage, generationTime) = await pipelineInterface.generateImage(config: genConfig)
                                            
                                            print("generating image finished")
                                        }
                                        generatingImage = false
                                        prevGenConfig = genConfig
                                        
                                    } else {
                                        print("no url found")
                                        showAlert=true
                                    }
                                }
                            }
                        }
                    
                    Desk(posPrompt: $posPrompt, showPopup: $showPopup)
                    

                    ModelSelectorView(resources: resources, url: $url, selectedModel: $selectedModel)
                        .hidden()
    
                    if showPopup {
                        // Semi-transparent background to indicate modal behavior
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // Dismiss the pop-up when the background is tapped
                                showPopup = false
                            }
                        // The pop-up content
                        ScrollView {
                            ModelSelectorView(resources: resources, url: $url, selectedModel: $selectedModel)
                            //
                            StyleSelectorView(styles: styles, selectedStyleIndex: $selectedStyleIndex, posStyle: $posStyle, negStyle: $negStyle, styleName: $styleName)
    
                            PromptFieldView(posPrompt: $posPrompt, negPrompt: $negPrompt)
    
    
                            RandomSeedSelectorView(randomSeed: $randomSeed, seedString: seedString)
    
//                            IterationsSelectorView(iterations: $iterations, iterationString: iterationString)
//
//                            GuidanceSelectorView(guidanceScale: $guidanceScale)
                            
                            Button(action: {
                                showPopup = false
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            
                            
//                            .foregroundColor(.white)
//                            .background(Color.red)
//                            .cornerRadius(10)
                            .padding()
                            
                        }

                        .background(Color.white)
                        .opacity(0.8)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .frame(width: w, height: h/2)
                        .position(x: w / 2, y: h * 0.3)
                    }
                }
                
            }
            .background(floorColor)
            .edgesIgnoringSafeArea(.all)
            
        }
        
    private func animateGradient() {
            withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                // Randomize the gradient's start and end points for the next cycle
                startPoint = UnitPoint.random
                endPoint = UnitPoint.random
            }
        }

}


extension UnitPoint {
    static var random: UnitPoint {
        UnitPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1))
    }
}


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
        .padding()
        .onAppear {
            if selectedResource != "" {
                updateSelectedResource(selectedResource)
            } else if let firstResource = resources.first {
                // Optionally, set the first resource as selected if nothing is initially selected
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

struct PromptFieldView: View {
    @Binding var posPrompt: String
    @Binding var negPrompt: String
    
    var body: some View{
        HStack {
            TextField("Positive Prompt", text: $posPrompt, axis: .vertical)
                .padding(12)
                .background(Color.green.opacity(0.3).cornerRadius(10))
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button( action: {
                            hideKeyboard()
                        }){
                            Image(systemName: "chevron.down")
                        }
                    }
                }
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}


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
                .keyboardType(.numberPad) // Show number pad keyboard
                .onChange(of: seedString) {
                    if let validNumber = UInt32(seedString) {
                        randomSeed = validNumber
                    }
                    
                }
        }
        .padding()
    }
}

struct IterationsSelectorView: View {
    @Binding var iterations: Int
    @State var iterationString: String
    
    var body: some View{
        HStack{
            Text("Iterations: ")
            TextField("\(iterations)", text: $iterationString)
                .keyboardType(.numberPad) // Show number pad keyboard
                .onChange(of: iterationString){
                    if let validNumber = Int(iterationString) {
                        iterations = validNumber
                    }
                }
        }
        
    }
}

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
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


import SwiftUI
import UIKit
import MobileCoreServices
import PhotosUI
import CoreML
import StableDiffusion

struct ContentView: View {
    
    @EnvironmentObject var dataModel: DataModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isPickerPresented: Bool = false
    @State var styleName: String = ""
    @State var posPrompt: String = "A cute golden retriever that is frolicking in the park with nothing to do but to run around in bliss"
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
    

    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var isExpanded = false
    @State private var showPopup = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top){
                MagicDrawer(parent: self, generatingImage: $generatingImage, generatedImage: $generatedImage, generationTime: $generationTime, posPrompt: $posPrompt)
                    .onChange(of: generatingImage){
                        Task{
                            if generatingImage == true {
                                let (posPromptStyled, negPromptStyled) = addStyle(posPrompt: posPrompt, posStyle: posStyle, negPrompt: negPrompt, negStyle: negStyle)
                                
                                print("pos prompt: \(posPromptStyled)")
                                print("neg prompt: \(negPromptStyled)")
                                
                                var genConfig = StableDiffusionPipeline.Configuration(prompt: posPromptStyled)
                                genConfig.negativePrompt = negPromptStyled
                                
                                genConfig.stepCount = iterations
                                genConfig.seed = randomSeed
                                genConfig.guidanceScale = guidanceScale
                                genConfig.disableSafety = false
                                genConfig.schedulerType = StableDiffusionScheduler.lcmScheduler
                                genConfig.useDenoisedIntermediates = true
                                
                                if let modelUrl = url {
                                    if genConfig != prevGenConfig{
                                        print("generating image")
                                        generatedImage = nil
                                        pipelineInterface.initModel(modelURL: modelUrl)
                                        
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
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showPopup = false
                        }
                    VStack {
                        ModelSelectorView(resources: resources, url: $url, selectedModel: $selectedModel)
                        StyleSelectorView(styles: styles, selectedStyleIndex: $selectedStyleIndex, posStyle: $posStyle, negStyle: $negStyle, styleName: $styleName)
                        PromptFieldView(posPrompt: $posPrompt, negPrompt: $negPrompt)
                        RandomSeedSelectorView(randomSeed: $randomSeed, seedString: seedString)
                        Button("Close") {
                            showPopup = false
                        }
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                    }

                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        
    }
}

    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

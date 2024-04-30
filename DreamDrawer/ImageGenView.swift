//
//  imageGenView.swift
//  CoreDiffuse
//
//  Created by David Wang on 2023-09-03.
//

import Foundation

import SwiftUI
import StableDiffusion
import CoreML
enum AttentionVariant: String {
    case original
    case splitEinsum
    case splitEinsumV2
}

extension AttentionVariant {
    var defaultComputeUnits: MLComputeUnits { self == .original ? .cpuAndGPU : .cpuAndNeuralEngine }
}



struct ImageGenView: View {
    @Binding var url: URL!
    @Binding var posPrompt: String
    @Binding var styledPosPrompt: String
    @Binding var negPrompt: String
    @Binding var styledNegPrompt: String
    @Binding var randomSeed: UInt32
    @Binding var iterations: Int
    @Binding var guidanceScale: Float

    @Binding var styleName: String
    
    @State private var finished: Bool = false
    @State private var isLoading = false
    @State var generatedImage: CGImage? = nil
    @State var imageGenerationTime: Double = 0.0
    @State var modelLoadingTime: Double = 0.0
    @State var modelLoaded = false
    @State var step = 0
    
    
    @ViewBuilder
    var body: some View{
        ScrollView{
            ZStack{
                VStack{
                    Button(action: {
                        finished=false
                        isLoading=true
                        step=0
                        DispatchQueue.global().async{
                            do {
                                modelLoaded = false
                                
                                let config = MLModelConfiguration()
//                                config.computeUnits = MLComputeUnits.cpuAndGPU
                                config.computeUnits = MLComputeUnits.cpuAndNeuralEngine
                                
                                var getPipeline: StableDiffusionPipelineProtocol?
                                
                                let modelInitTime = Date()
                                
                                getPipeline = try StableDiffusionPipeline(resourcesAt: url,
                                                                          controlNet: [],
                                                                          configuration: config,
                                                                          reduceMemory: true)
                                
                                guard let pipeline = getPipeline else {
                                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to initialize pipeline"])
                                }
                                
                                try pipeline.loadResources()
                                
                                
                                let modelLoadedTime = Date()
                                modelLoadingTime = modelLoadedTime.timeIntervalSince(modelInitTime)
                                modelLoaded = true
                                
                                print("pipeline resources loaded in \(modelLoadingTime) s!")
                                
                                
                                var genConfig = StableDiffusionPipeline.Configuration(prompt: styledPosPrompt)
                                
                                
                                genConfig.negativePrompt = negPrompt + styledNegPrompt
                                genConfig.stepCount = iterations
                                genConfig.seed = randomSeed
                                genConfig.guidanceScale = guidanceScale
                                genConfig.disableSafety = true
                                genConfig.schedulerType = StableDiffusionScheduler.dpmSolverMultistepScheduler
                                genConfig.useDenoisedIntermediates = true
                     
                                let imageGenStartTime = Date()
                                let images = try pipeline.generateImages(configuration: genConfig, progressHandler: { progress in
                                    step = progress.step
                                    return true
                                })
                                let imageGenEndTime = Date()
                                imageGenerationTime = imageGenEndTime.timeIntervalSince(imageGenStartTime)
                                
                                let image = images.compactMap({ $0 }).first
                                generatedImage = image
                                
                                DispatchQueue.main.async{
                                    isLoading=false
                                }
                                finished = true
                            } catch {
                                // Handle the error
                                print(error)
                                DispatchQueue.main.async{
                                    isLoading=false
                                }
                            }
                        }
                    }) {
                        Text("Generate Image")
                    }
                    .padding()
                    .background(Color.green.cornerRadius(20))
                    .disabled(isLoading)
                    
                    
                }
                if isLoading{
                    ProgressView()
                }
            }
        
        
        
        
            VStack{
                Text("Model: \(url?.lastPathComponent ?? "None")")
                    .background(Color.blue.opacity(0.3).cornerRadius(10))
                Text("Pos: \(posPrompt)")
                    .background(Color.green.opacity(0.3).cornerRadius(10))
                Text("Neg: \(negPrompt)")
                    .background(Color.red.opacity(0.3).cornerRadius(10))
                Text("Style: \(styleName)")
                HStack{
                    Text(verbatim: "seed \(randomSeed)")
                    Text("iterations \(iterations)")
                    Text("guidance \(guidanceScale, specifier: "%.1f")")
                }

            }
            
            
            if finished{
                if generatedImage != nil{
                    let imageToShow = UIImage(cgImage: generatedImage!)
                    Text("Model loaded in \(modelLoadingTime)s")
                    Text("\(iterations) steps diffused in \(imageGenerationTime) s")
                    let image = Image(uiImage: imageToShow)
                    VStack{
                        image
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
//                                .scaledToFit()
//                                .frame(width: 512, height: 512) // Define frame size to ensure it's square
////                                .clipped() // Clip the image to the frame's bounds
                            .padding()
                        ShareLink(item: image, preview: SharePreview("\(posPrompt)", image: image))
                    }
                    
                } else{
                    Text("no image was generated")
                }
                
            }
            else {
                if modelLoaded{
                    Text("Model loaded in \(modelLoadingTime)s")
                    Text("generating image")
                        .padding()
                    HStack{
                        ProgressView(value: Double(step+1), total: Double(iterations))
                            .padding()
                        Text("\(step+1) / \(iterations)")
                    }
                    
                } else{
                    if isLoading{
                        Text("loading the model ...")
                        Text("(this will be slow the first time)")
                    }
                }
            }
            
        }
    }
    
    
}
//struct ImageGenViewPreviewContainer: View{
//    @State
//    private var imageDiffuserModel: ImageDiffuser
//    var body: some View{
//        ImageGenView(imageDiffuserModel: $imageDiffuserModel)
//    }
//}
//struct ImageGenView_Previews: PreviewProvider {
//
//
//    static var previews: some View {
//        ImageGenViewPreviewContainer()
//    }
//}


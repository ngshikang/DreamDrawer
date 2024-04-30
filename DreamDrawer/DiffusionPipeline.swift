//
//  DiffusionPipeline.swift
//  DreamDrawer
//
//  Created by David Wang on 2024-03-24.
//

import Foundation
import SwiftUI
import StableDiffusion
import CoreML

class DiffusionPipeline: ObservableObject {
    @Published var modelLoaded: Bool = false
    var onGenerationStepChanged: ((Int) -> Void)?
    
    var pipeline: StableDiffusionPipelineProtocol?
    var modelURL: URL
    var modelConfiguration: MLModelConfiguration

    public init(modelURL: URL, modelConfiguration: MLModelConfiguration){
        self.modelURL = modelURL
        self.modelConfiguration = modelConfiguration
    }
    
    public func loadPipeline() async{
        
        do {
            pipeline = try StableDiffusionPipeline(resourcesAt: modelURL,
                                                  controlNet: [],
                                                  configuration: modelConfiguration,
                                                  reduceMemory: true)
            try pipeline!.loadResources()
            
            modelLoaded = true
            
        } catch {
            print("couldn't init model")
        }
        
    }
    
    public func generateImage(config: PipelineConfiguration) async -> (CGImage?, TimeInterval){
        if !modelLoaded{
            await loadPipeline()
        }
        var generatedImage: CGImage? = nil
        
        let imageGenStartTime = Date()
        do {
            let images = try pipeline!.generateImages(configuration: config, progressHandler: { progress in
                DispatchQueue.main.async {
                    self.onGenerationStepChanged?(progress.step)
                }
                return true
            })
            generatedImage = images.compactMap({ $0 }).first
        } catch {
            print("couldn't generate images")
        }
        
        let imageGenEndTime = Date()
        let imageGenerationTime = imageGenEndTime.timeIntervalSince(imageGenStartTime)
        
        return (generatedImage, imageGenerationTime)
        
    }
    
}

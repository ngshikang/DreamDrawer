//
//  PipelineInterface.swift
//  DreamDrawer
//
//  Created by David Wang on 2024-03-31.
//

import Foundation
import SwiftUI
import StableDiffusion
import CoreML

class PipelineInterface: ObservableObject {
    
    var pipelines: [URL: DiffusionPipeline] = [:]
    var selectedPipeline: DiffusionPipeline? = nil
    @Published var generationStep: Int = 0
    
    public func initModel(modelURL: URL){
        let modelConfiguration = MLModelConfiguration()
        modelConfiguration.computeUnits = .cpuAndNeuralEngine
        
        if pipelines[modelURL] == nil{
            pipelines[modelURL] = DiffusionPipeline(modelURL: modelURL, modelConfiguration: modelConfiguration)
        }
        
        selectedPipeline = pipelines[modelURL]
        
        selectedPipeline?.onGenerationStepChanged = { [weak self] newStep in
//            self?.generationStep = newStep
        }
    }
    
    public func generateImage(config: PipelineConfiguration) async -> (CGImage?, TimeInterval){
        if let pipeline = selectedPipeline{
            return await pipeline.generateImage(config: config)
        } else {
            return (nil, TimeInterval(1))
        }
    }
}

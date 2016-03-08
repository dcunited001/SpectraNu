//
//  BufferAllocatorGenerator.swift
//  
//
//  Created by David Conner on 3/8/16.
//
//

import Foundation
import Swinject
import ModelIO
import Metal
import MetalKit

public protocol BufferAllocatorGenerator {
    init(container: Container, args: [String: GeneratorArg])
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLMeshBufferAllocator
    // nocopy
}

public class MTKMeshBufferAllocatorGenerator: BufferAllocatorGenerator {
    var deviceRef: String? = "default"
    var device: MTLDevice?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let deviceRef = args["device"] {
            self.deviceRef = deviceRef.value
        }
    }
    
    // users can either manually set the device, 
    // - or expect that it is available from within the container
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMeshBufferAllocator {
        if device != nil {
            return MTKMeshBufferAllocator(device: device!)
        } else {
            let deviceRef = self.deviceRef ?? "default"
            let device = container.resolve(MTLDevice.self, name: deviceRef)!
            return MTKMeshBufferAllocator(device: device)
        }
    }
}
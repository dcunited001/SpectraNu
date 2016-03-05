//
//  BasicTessellationGenerators.swift
//  
//
//  Created by David Conner on 3/5/16.
//
//

import Foundation
import Metal
import ModelIO
import simd

public class BasicTessellationGenerators {
    public static func loadMeshGenerators(container: Container) {
        
    }
}

// TODO: decide on whether the distinction between generators for each 
//   primitive should be at the class level

public class MidpointTessellationMeshGen: MeshGenerator {
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}

public class SierpenskiTessellationMeshGen: MeshGenerator {
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}


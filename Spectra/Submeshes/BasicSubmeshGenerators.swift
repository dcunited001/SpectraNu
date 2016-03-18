//
//  BasicSubmeshGenerators.swift
//  
//
//  Created by David Conner on 3/11/16.
//
//

import Foundation
import Metal
import ModelIO
import simd
import Swinject

// TODO: how to compose various functionalities together?

// Model I/O generators create meshes using a VertexDescriptor with:
// - position: 12B
// - normal: 12B
// - textureCoordinates: 8B

public class BasicSubmeshGenerators {
    public static func loadGenerators(container: Container) {
        container.register(TriangulationDelauney2DSubmeshGen.self, name: "triangulation_delauney_2d_submesh_gen") { _ in
            return TriangulationDelauney2DSubmeshGen(container: container)
        }.inObjectScope(.None)
    }
}

public class TriangulationDelauney2DSubmeshGen: SubmeshGenerator {
    // i really have no idea how to implement this lmaoz
    
    // TODO: submesh primitive type?
    // TODO: submesh topology type?
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var indexType: MDLIndexBitDepth = .UInt16
//    public var topology:

    public required init(container: Container, args: [String : GeneratorArg] = [:]) {
        processArgs(container, args: args)
    }
    
    public func generate(container: Container, args: [String : GeneratorArg]) -> MDLSubmesh {
        return MDLSubmesh()
    }
    
    public func processArgs(container: Container, args: [String : GeneratorArg]) {
        // TODO: implement
    }
    
    public func copy(container: Container) -> SubmeshGenerator {
        let cp = TriangulationDelauney2DSubmeshGen(container: container)
        // TODO: complete after determining args & parameters
        cp.geometryType = self.geometryType
        return cp
    }
}

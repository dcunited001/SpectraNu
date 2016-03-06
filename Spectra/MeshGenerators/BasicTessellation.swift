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
import Swinject
import simd

public class BasicTessellationGenerators {
    public static func loadMeshGenerators(container: Container) {
        
    }
}

// TODO: decide on whether the distinction between generators for each 
//   primitive should be at the class level

public class MidpointTessellationMeshGen: MeshGenerator {
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var mesh: MDLMesh?
    public var numDivisions: Int = 1 // number of divisions per step
    public var numIterations: Int = 1
    
    // should this require an edge submesh?
    // - if it lacks an edge submesh, it should construct one
    
    // allow user to specify mesh generator instead of a pre-existing mesh?
    // how to specify blocks to handle parameters? 
    //  - like normals, anisotropy, etc
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let meshKey = args["mesh"] {
            self.mesh = container.resolve(MDLMesh.self, name: meshKey.value)
        }
        if let geoType = args["geometryType"] {
            self.geometryType = .TypeTriangles
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}

public class SierpenskiTessellationMeshGen: MeshGenerator {
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var mesh: MDLMesh?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let meshKey = args["mesh"] {
            self.mesh = container.resolve(MDLMesh.self, name: meshKey.value)
        }
        if let geoType = args["geometryType"] {
            self.geometryType = .TypeTriangles
        }
        
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}

//
//  TriangularQuadTesselationGenerator.swift
//  Pods
//
//  Created by David Conner on 10/22/15.
//
//

//import Foundation
//import simd
//
//public class TriangularQuadTesselationGenerator: MeshGenerator {
//
//    var rowCount: Int = 10
//    var colCount: Int = 10
//
//    public required init(args: [String: String] = [:]) {
//        if let rCount = args["rowCount"] {
//            rowCount = Int(rCount)!
//        }
//        if let cCount = args["colCount"] {
//            colCount = Int(cCount)!
//        }
//    }
//
//    public func getData(args: [String: AnyObject] = [:]) -> [String:[float4]] {
//        return [
//            "pos": getVertices(args),
//            "rgba": getColorCoords(args),
//            "tex": getTexCoords(args)
//        ]
//    }
//
//    public func getDataMaps(args: [String: AnyObject] = [:]) -> [String:[[Int]]] {
//        return [
//            "triangle_vertex_map": getTriangleVertexMap(args),
//            "face_vertex_map": getFaceVertexMap(args),
//            "face_triangle_map": getFaceTriangleMap(args)
//        ]
//    }
//
//    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
//        return []
//    }
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return []
//    }
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return []
//    }
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return []
//    }
//    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return []
//    }
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return []
//    }
//}
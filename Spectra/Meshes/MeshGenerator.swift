//
//  MeshGenerator.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import ModelIO
import simd
import Swinject

public protocol MeshGenerator {
    init(container: Container, args: [String: GeneratorArg])
    
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLMesh
    func processArgs(container: Container, args: [String: GeneratorArg])
    func copy(container: Container) -> MeshGenerator
}

//public typealias MeshGeneratorMonad = ((Container, ) -> )

// NOTE: trying to decouple SpectraGeo from the rest of Spectra
// - or at least parts of it

public class SpectraGeo {
    
    public static func defaultVertexDescriptor() -> MDLVertexDescriptor {
        // this vertex desc can be replaced,
        // - but this descriptor describes the data layout
        
        let attrPos = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .Float4, offset: 0, bufferIndex: 0)
        let attrColor = MDLVertexAttribute(name: MDLVertexAttributeColor, format: .Int4, offset: 0, bufferIndex: 1)
        let attrTex = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .Float4, offset: 0, bufferIndex: 2)
        let attrNorm = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .Float4, offset: 0, bufferIndex: 3)
        
        let desc = MDLVertexDescriptor()
        desc.addOrReplaceAttribute(attrPos)
        desc.addOrReplaceAttribute(attrColor)
        desc.addOrReplaceAttribute(attrTex)
        desc.addOrReplaceAttribute(attrNorm)
        
        return desc
    }
    
    // TODO: move this elsewhere

//    public static func getClassForVertexFormat(vertexFormat: MDLVertexFormat) -> Any {
//        switch vertexFormat {
        // TODO: i had hoped to use return the class here, then reference this in the generateData() method
        // - to infer type on a variable that would receive the value from the generic generateAttribute() method
        // - but i can't really do much with structs =/
//        }
//    }
    
}

//public class BasicTriangleGenerator: MeshGenerator {
//
//    public required init(args: [String: String] = [:]) {
//
//    }
//
//    public func getData(args: [String: AnyObject] = [:]) -> [String:[float4]] {
//        return [
//            "pos": getVertices(),
//            "rgba": getColorCoords(),
//            "tex": getTexCoords()
//        ]
//    }
//
//    public func getDataMaps(args: [String: AnyObject] = [:]) -> [String:[[Int]]] {
//        return [
//            "triangle_vertex_map": getTriangleVertexMap(),
//            "face_vertex_map": getFaceVertexMap(),
//            "face_triangle_map": getFaceTriangleMap()
//        ]
//    }
//
//    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            // isosoles triangle
//            float4(0.0,  0.0, 0.0, 1.0),
//            float4(-1.0, 1.0, 0.0, 1.0),
//            float4(1.0,  1.0, 0.0, 1.0)
//        ]
//    }
//
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 0.0, 0.0, 1.0),
//            float4(0.0, 1.0, 0.0, 1.0),
//            float4(0.0, 0.0, 1.0, 1.0)
//        ]
//    }
//
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(0.5, 0.0, 0.0, 1.0),
//            float4(0.0, 1.0, 0.0, 1.0),
//            float4(1.0, 1.0, 1.0, 1.0)
//        ]
//    }
//
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [[0,1,2]]
//    }
//
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [[0,1,2]]
//    }
//
//    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [[0]]
//    }
//}

//public class QuadGenerator: MeshGenerator {
//
//    public required init(args: [String: String] = [:]) {
//
//    }
//
//    public func getData(args: [String: AnyObject] = [:]) -> [String:[float4]] {
//        return [
//            "pos": getVertices(),
//            "rgba": getColorCoords(),
//            "tex": getTexCoords()
//        ]
//    }
//
//    public func getDataMaps(args: [String: AnyObject] = [:]) -> [String:[[Int]]] {
//        return [
//            "triangle_vertex_map": getTriangleVertexMap(),
//            "face_vertex_map": getFaceVertexMap(),
//            "face_triangle_map": getFaceTriangleMap()
//        ]
//    }
//
//    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(-1.0, -1.0, 0.0, 1.0),
//            float4(-1.0,  1.0, 0.0, 1.0),
//            float4( 1.0, -1.0, 0.0, 1.0),
//            float4( 1.0,  1.0, 0.0, 1.0)
//        ]
//    }
//
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 0.0, 0.0, 1.0),
//            float4(0.0, 1.0, 0.0, 1.0),
//            float4(0.0, 0.0, 1.0, 1.0),
//            float4(1.0, 1.0, 0.0, 1.0)
//        ]
//    }
//
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(0.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(1.0, 1.0, 0.0, 0.0)
//        ]
//    }
//
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [
//            [0,1,3],
//            [3,2,0]
//        ]
//    }
//
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [[0,1,2,3]]
//    }
//
//    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [[0,1]]
//    }
//}






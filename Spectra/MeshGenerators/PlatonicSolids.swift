//
//  PlatonicSolids.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd
import Swinject
import Metal
import ModelIO

//N.B. textures are 1-to-1 with vertex-face map
// - for simple 3d objects

//TODO: change "size" to "radius"

public class PlatonicSolidMeshGenerators {
    public static func loadMeshGenerators(container: Container) {
        container.register(MeshGenerator.self, name: "tetrahedron_mesh_gen") { _ in
            return TetrahedronMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "cube_mesh_gen") { _ in
            return CubeMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "octahedron_mesh_gen") { _ in
            return OctahedronMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "dodecahedron_mesh_gen") { _ in
            return DodecahedronMeshGen(container: container)
        }
        // icosahedron is defined in Model I/O
    }
}

public class TetrahedronMeshGen: MeshGenerator {
    public var size: Float = 10.0
    public var geometryType: MDLGeometryType = .TypeTriangles
    
    public var vertexDescriptor: MDLVertexDescriptor = SpectraGeo.defaultVertexDescriptor()
    public var meshData: [String: [AnyObject]] = [:]
    public var subMeshData: [String: [AnyObject]] = [:]
    
    // optional generator functions for vertex data
    // - but how to account for various sizes
    public var positionGenerator: (() -> AnyObject)?
    public var colorGenerator: (() -> AnyObject)?
    public var textureGenerator: (() -> AnyObject)?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let size = args["size"] {
            self.size = Float(size.value)!
        }
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        
        //populate meshData & subMeshData
        
        // TODO: generate data
        
//        let positionType = self.vertexDescriptor.attributeNamed(MDLVertexDescriptorPosition)
//        let positionData:[] = generateAttribute
        
        return MDLMesh()
    }
    
//    public func generateAttribute<T>() -> [T] {
//        
//    }
}

//    //   Q --- R
//    //  /|    /|
//    // A --- B |
//    // | T --| S
//    // |/    |/
//    // D --- C
public class CubeMeshGen: MeshGenerator {
    public var size: Float = 10.0
    public var geometryType: MDLGeometryType = .TypeTriangles
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let size = args["size"] {
            self.size = Float(size.value)!
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}

public class OctahedronMeshGen: MeshGenerator {
    public var size: Float = 10.0
    public var geometryType: MDLGeometryType = .TypeTriangles
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let size = args["size"] {
            self.size = Float(size.value)!
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}

public class DodecahedronMeshGen: MeshGenerator {
    public var size: Float = 10.0
    public var geometryType: MDLGeometryType = .TypeTriangles
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let size = args["size"] {
            self.size = Float(size.value)!
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
    }
}


//public class TetrahedronGenerator: MeshGenerator {
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
//            float4( 1.0,  1.0,  1.0, 1.0),
//            float4(-1.0,  1.0, -1.0, 1.0),
//            float4( 1.0, -1.0, -1.0, 1.0),
//            float4(-1.0, -1.0,  1.0, 1.0)
//        ]
//    }
//    
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 1.0, 1.0, 1.0),
//            float4(1.0, 0.0, 0.0, 1.0),
//            float4(0.0, 1.0, 0.0, 1.0),
//            float4(0.0, 0.0, 1.0, 1.0)
//        ]
//    }
//    
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(0.0, 0.0, 0.0, 0.0)
//        ]
//    }
//    
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [
//            [0,1,2],
//            [1,3,2],
//            [0,2,3],
//            [0,3,1]
//        ]
//    }
//    
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return getTriangleVertexMap()
//    }
//    
//    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return (0...3).map { [$0] }
//    }
//}
//
//public class OctahedronGenerator: MeshGenerator {
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
//    let A = Float(1 / (2 * sqrt(2.0)))
//    let B = Float(1 / 2.0)
//    
//    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4( 0,  B,  0, 1.0),
//            float4( A,  0,  A, 1.0),
//            float4( A,  0, -A, 1.0),
//            float4(-A,  0,  A, 1.0),
//            float4(-A,  0, -A, 1.0),
//            float4( 0, -B,  0, 1.0)
//        ]
//    }
//
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 1.0, 1.0, 1.0), // white
//            float4(1.0, 0.0, 0.0, 1.0), // red
//            float4(0.0, 1.0, 0.0, 1.0), // blue
//            float4(0.0, 0.0, 1.0, 1.0), // green
//            float4(1.0, 1.0, 0.0, 1.0), // yellow
//            float4(0.0, 0.0, 0.0, 0.0), // transparent
//        ]
//    }
//
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(0.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(1.0, 1.0, 0.0, 0.0)
//        ]
//    }
//
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return [
//            [0,1,2],
//            [0,2,3],
//            [0,3,4],
//            [0,4,1],
//            [5,1,2],
//            [5,2,3],
//            [5,3,4],
//            [5,4,1]
//        ]
//    }
//
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return getTriangleVertexMap(args)
//    }
//    
//    public func getFaceTriangleMap() -> [[Int]] {
//        return (0...7).map { [$0] }
//    }
//}
//
//http://paulbourke.net/geometry/platonic/
//public class IcosahedronGenerator: MeshGenerator { }
//public class DodecahderonGenerator: MeshGenerator { }
//public class Dodecahderon2Generator: MeshGenerator { }
// - where vertex in center of pentagons
//class Dodecahderon3: MeshGenerator { }
// - with overlapping triangles

//public class TetrahedronGenerator: MeshGenerator {
//    func getVertices() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getColorCoords() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getTexCoords() -> [float4] {
//        return [
//            
//        ]
//    }
//    
//    func getTriangleVertexMap() -> [[Int]] {
//        return [[]]
//    }
//    
//    func getFaceVertexMap() -> [[Int]] {
//        return [[]]
//    }
//}

//
//  Cube.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

//public class CubeGenerator: MeshGenerator {
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
//    // return a node
//    // - with a list of vertices
//    // - with a list of colorvertices
//    // - with a list of textureVertices
//    // - a map of vertices to triangles (& reverse?)
//    // - a map of vertices to faces (& reverse?)
//
//    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(-1.0,  1.0,  1.0, 1.0),
//            float4(-1.0, -1.0,  1.0, 1.0),
//            float4( 1.0, -1.0,  1.0, 1.0),
//            float4( 1.0,  1.0,  1.0, 1.0),
//            float4(-1.0,  1.0, -1.0, 1.0),
//            float4( 1.0,  1.0, -1.0, 1.0),
//            float4(-1.0, -1.0, -1.0, 1.0),
//            float4( 1.0, -1.0, -1.0, 1.0)
//        ]
//    }
//
//    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(1.0, 1.0, 1.0, 1.0),
//            float4(0.0, 1.0, 1.0, 1.0),
//            float4(1.0, 0.0, 1.0, 1.0),
//            float4(1.0, 0.0, 0.0, 1.0),
//            float4(0.0, 0.0, 1.0, 1.0),
//            float4(1.0, 1.0, 0.0, 1.0),
//            float4(0.0, 1.0, 0.0, 1.0),
//            float4(0.0, 0.0, 0.0, 1.0)
//        ]
//    }
//
//    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
//        return [
//            float4(0.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(1.0, 1.0, 0.0, 0.0),
//            float4(1.0, 1.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0),
//            float4(1.0, 0.0, 0.0, 0.0),
//            float4(0.0, 1.0, 0.0, 0.0)
//        ]
//    }
//
//    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        let A = 0
//        let B = 1
//        let C = 2
//        let D = 3
//        let Q = 4
//        let R = 5
//        let S = 6
//        let T = 7
//
//        return [
//            [A,B,C], [A,C,D],   //Front
//            [R,T,S], [Q,R,S],   //Back
//
//            [Q,S,B], [Q,B,A],   //Left
//            [D,C,T], [D,T,R],   //Right
//
//            [Q,A,D], [Q,D,R],   //Top
//            [B,S,T], [B,T,C]   //Bottom
//        ]
//    }
//
//    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        let A = 0
//        let B = 1
//        let C = 2
//        let D = 3
//        let Q = 4
//        let R = 5
//        let S = 6
//        let T = 7
//
//        //needs to be rewritten,
//        // - so that vertices of face are invariant for rotations
//        return [
//            [A,B,C,D],   //Front
//            [Q,R,S,T],   //Back
//
//            [Q,A,D,T],   //Left
//            [B,R,S,C],   //Right
//
//            [Q,R,B,A],   //Top
//            [T,S,C,D]   //Bottom
//        ]
//    }
//
//    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
//        return (0...5).map { [2 * $0, 2 * $0 + 1] }
//    }
//
////    func getTextureVertices() -> [float4] {
////        return [
////
////        ]
////    }
//
//}

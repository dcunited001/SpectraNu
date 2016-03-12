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

public class EllipsoidMeshGen: MeshGenerator {
    public var radii = float3(10.0, 10.0, 10.0)
    public var radialSegments: Int = 30
    public var verticalSegments: Int = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals: Bool = false
    public var hemisphere: Bool = false

    // TODO: should user be able to attach a buffer allocator to the instance?
    // - allowing both this and accessing allocators from the container may complicate the interface
    // - yet, accessing everything from a single container means that one giant D/I container needs to be passed around (very bad, when parallelism is needed)

    // NOTE: another option would be to pass around a (ContainerMap, ResourceInjectionClosure) tuple
    // typealias ContainerMap = [String: Container]
    // typealias ResourceInjectionClosure = (ContainerMap) -> [String: AnyObject]

    public weak var allocator: MDLMeshBufferAllocator?

    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        processArgs(container, args: args)
    }

    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
        if let radii = args["radii"] {
            self.radii = SpectraSimd.parseFloat3(radii.value)
        }
        if let radialSegments = args["radial_segments"] {
            self.radialSegments = Int(radialSegments.value)!
        }
        if let verticalSegments = args["vertical_segments"] {
            self.verticalSegments = Int(verticalSegments.value)!
        }
        if let geoType = args["geometry_type"] {
            let enumVal = container.resolve(SpectraEnum.self, name: "mdlGeometryType")!.getValue(geoType.value)
            self.geometryType = MDLGeometryType(rawValue: Int(enumVal))!
        }
        if let inwardNormals = args["inward_normals"] {
            let valAsBool = NSString(string: inwardNormals.value).boolValue
            self.inwardNormals = valAsBool
        }
        if let hemisphere = args["hemisphere"] {
            let valAsBool = NSString(string: hemisphere.value).boolValue
            self.hemisphere = valAsBool
        }

        // TODO: buffer allocator
    }

    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        // TODO: merge arguments for mesh generators

        return MDLMesh.newEllipsoidWithRadii(self.radii,
            radialSegments: self.radialSegments,
            verticalSegments: self.verticalSegments,
            geometryType: self.geometryType,
            inwardNormals: self.inwardNormals,
            hemisphere: self.hemisphere,
            allocator: allocator)
    }

    public func copy(container: Container) -> MeshGenerator {

        let cp = EllipsoidMeshGen(container: container)
        cp.radii = self.radii
        cp.radialSegments = self.radialSegments
        cp.verticalSegments = self.verticalSegments
        cp.geometryType = self.geometryType
        cp.inwardNormals = self.inwardNormals
        cp.hemisphere = self.hemisphere
        // buffer allocator

        return cp
    }
}


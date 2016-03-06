//
//  MDLMeshGenerators.swift
//  
//
//  Created by David Conner on 3/4/16.
//
//

import Foundation
import Metal
import ModelIO
import simd
import Swinject

// TODO: how to compose various functionalities together?

public class ModelIOMeshGenerators {
    
    public static func loadMeshGenerators(container: Container) {
        container.register(MeshGenerator.self, name: "box_mesh_gen") { _ in
            return BoxMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "ellipsoid_mesh_gen") { _ in
            return EllipsoidMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "elliptical_cone_mesh_gen") { _ in
            return EllipticalConeMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "plane_mesh_gen") { _ in
            return PlaneMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "icosahedron_mesh_gen") { _ in
            return IcosahedronMeshGen(container: container)
        }
        container.register(MeshGenerator.self, name: "subdivision_mesh_gen") { _ in
            return SubdivisionMeshGen(container: container)
        }
    }
}


public class BoxMeshGen: MeshGenerator {
    
    public var dimensions: float3 = [10.0, 10.0, 10.0]
    public var segments: int3 = [10, 10, 10] // vector_uint3 ??
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals: Bool = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
        if let dimensions = args["dimensions"] {
            self.dimensions = SpectraSimd.parseFloat3(dimensions.value)
        }
        if let segments = args["segments"] {
            self.segments = SpectraSimd.parseInt3(segments.value)
        }
        if let geoType = args["geometry_type"] {
            // self.geometryType = .TypeTriangles
        }
        if let inwardNormals = args["inward_normals"] {
            let valAsBool = NSString(string: inwardNormals.value).boolValue
            self.inwardNormals = valAsBool
        }
        //TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
        
        // TODO: removed from Model I/O API?  It's still accessible in source
//        return MDLMesh.newBoxWithDimensions(self.dimensions,
//                                            segments: self.segments,
//                                            geometryType: self.geometryType,
//                                            inwardNormals: self.inwardNormals,
//                                            allocator: allocator)
    }
}

//TODO: triangle generator
//TODO: cube gen
//TODO:

public class EllipsoidMeshGen: MeshGenerator {
    public var radii = float3(10.0, 10.0, 10.0)
    public var radialSegments: Int = 30
    public var verticalSegments: Int = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals: Bool = false
    public var hemisphere: Bool = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
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
            // self.geometryType = .TypeTriangles
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
}

public class EllipticalConeMeshGen: MeshGenerator {
    public var height: Float = 10.0
    public var radii: float2 = float2(10.0, 10.0)
    public var radialSegments: Int = 30
    public var verticalSegments: Int = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let height = args["height"] {
            self.height = Float(height.value)!
        }
        if let radii = args["radii"] {
            self.radii = SpectraSimd.parseFloat2(radii.value)
        }
        if let radialSegments = args["radial-segments"] {
            self.radialSegments = Int(radialSegments.value)!
        }
        if let verticalSegments = args["vertical-segments"] {
            self.verticalSegments = Int(verticalSegments.value)!
        }
        if let geometryType = args["geometry-type"] {
            self.geometryType = .TypeTriangles
        }
        if let inwardNormals = args["inward_normals"] {
            let valAsBool = NSString(string: inwardNormals.value).boolValue
            self.inwardNormals = valAsBool
        }
        
        // TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        
        return MDLMesh.newEllipticalConeWithHeight(self.height,
            radii: self.radii,
            radialSegments: self.radialSegments,
            verticalSegments: self.verticalSegments,
            geometryType: .TypeTriangles,
            inwardNormals: self.inwardNormals,
            allocator: nil)
    }
}

public class CylinderMeshGen: MeshGenerator {
    public var height: Float = 10.0
    public var radii = float2(10.0, 10.0)
    public var radialSegments: Int = 30
    public var verticalSegments: Int = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let height = args["height"] {
            self.height = Float(height.value)!
        }
        if let radii = args["radii"] {
            self.radii = SpectraSimd.parseFloat2(radii.value)
        }
        if let radialSegments = args["radial-segments"] {
            self.radialSegments = Int(radialSegments.value)!
        }
        if let verticalSegments = args["vertical-segments"] {
            self.verticalSegments = Int(verticalSegments.value)!
        }
        if let geometryType = args["geometry-type"] {
            self.geometryType = .TypeTriangles
        }
        
        // TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh.newCylinderWithHeight(self.height,
            radii: self.radii,
            radialSegments: self.radialSegments,
            verticalSegments: self.verticalSegments,
            geometryType: .TypeTriangles,
            inwardNormals: self.inwardNormals,
            allocator: self.allocator)
    }
}

public class PlaneMeshGen: MeshGenerator {
    public var dimensions: float2 = float2(10.0, 10.0)
    public var segments: int2 = int2(10, 10)
    public var geometryType: MDLGeometryType = .TypeTriangles
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let dimensions = args["dimensions"] {
            self.dimensions = SpectraSimd.parseFloat2(dimensions.value)
        }
        
        if let segments = args["segments"] {
            self.segments = SpectraSimd.parseInt2(segments.value)
        }
        
        if let geometryType = args["geometry-type"] {
            self.geometryType = .TypeTriangles
        }
        
        // TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh()
//        return MDLMesh.newPlaneWithDimensions(self.dimensions,
//                                              segments: self.segments,
//                                              geometryType: self.geometryType,
//                                              allocator: self.allocator)
    }
}

public class IcosahedronMeshGen: MeshGenerator {
    public var radius: Float = 10.0
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let radius = args["radius"] {
            self.radius = Float(radius.value)!
        }
        if let inwardNormals = args["inward_normals"] {
            let valAsBool = NSString(string: inwardNormals.value).boolValue
            self.inwardNormals = valAsBool
        }
        
        // TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh.newIcosahedronWithRadius(self.radius,
                                                inwardNormals: self.inwardNormals,
                                                allocator: self.allocator)
    }
}

public class SubdivisionMeshGen: MeshGenerator {
    public var mesh: MDLMesh?
    public var submeshIndex: Int = 0
    public var subdivisionLevels: Int = 1
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let meshKey = args["mesh"] {
            self.mesh = container.resolve(MDLMesh.self, name: meshKey.value)
        }
        if let submeshIndex = args["submesh-index"] {
            self.submeshIndex = Int(submeshIndex.value)!
        }
        if let subdivisionLevels = args["subdivision-levels"] {
            self.subdivisionLevels = Int(subdivisionLevels.value)!
        }
    }
    
    public func generate(container: Container, args: [String : GeneratorArg]) -> MDLMesh {
        return MDLMesh.newSubdividedMesh(self.mesh!,
                                         submeshIndex: self.submeshIndex,
                                         subdivisionLevels: self.subdivisionLevels)!
    }
}

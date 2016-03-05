//
//  MDLMeshGenerators.swift
//  
//
//  Created by David Conner on 3/4/16.
//
//

import Foundation

//TODO: decide on how to find MDLMeshBufferAllocators for generate?
// - change API? add allocator: MDLMeshBufferAllocator to generate()?
// - or add a container to generate()?
//   - i like this the best
// - or force user to set gen.allocator before calling generate()? this makes API a bit more bumbly & awkward

//        newBoxWithDimensions:(vector_float3)dimensions
//        segments:(vector_uint3)segments
//        geometryType:(MDLGeometryType)geometryType
//        inwardNormals:(BOOL)inwardNormals
//        allocator:(id<MDLMeshBufferAllocator>)allocator

// TODO: evaluate adding container:Container to API for init() & generate()
// - as i said above, this seems like the best option, but i donno

// TODO: how to compose various functionalities together?

public class ModelIOMeshGenerators {
    
    public static func loadMeshGenerators(container: Container) {
        container.register(MeshGenerator.self, name: "boxMeshGen") { _ in
            return BoxMeshGen()
        }
        container.register(MeshGenerator.self, name: "") { _ in
            return EllipsoidMeshGen()
        }
        container.register(MeshGenerator.self, name: "") { _ in
            return EllipticalConeMeshGen()
        }
        container.register(MeshGenerator.self, name: "") { _ in
            return PlaneDimMeshGen()
        }
        container.register(MeshGenerator.self, name: "") { _ in
            return IcosohedronMeshGen()
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
        return MDLMesh.newBoxWithDimensions(self.dimensions,
                                            segments: self.segments,
                                            geometryType: self.geometryType,
                                            inwardNormals: self.inwardNormals,
                                            allocator: allocator)
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
    public var radialSegments = 30
    public var verticalSegments = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        if let height = args["height"] {
            self.height = Float(height)
        }
        
        if let radii = args["radii"] {
            self.radii = radii
        }
        
        if let radialSegments = args["radial-segments"] {
            self.radialSegments = radialSegments
        }
        
        if let verticalSegments = args["vertical-segments"] {
            self.verticalSegments = verticalSegments
        }
        
        if let geometryType = args["geometry-type"] {
            self.geometryType = geometryType
        }
        
        if let inwardNormals = args["inward-normals"] {
            self.inwardNormals = inwardNormals
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
    public var radialSegments = 30
    public var verticalSegments = 10
    public var geometryType: MDLGeometryType = .TypeTriangles
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
        
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
    public var dimensions = float2(10.0, 10.0)
    public var segments = int2(10, 10)
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
        return MDLMesh.newPlaneWithDimensions(dimensions,
                                              segments: self.segments,
                                              geometryType: self.geometryType,
                                              allocator: self.allocator)
    }
}

public class IcosohedronMeshGen: MeshGenerator {
    public var radius = 10.0
    public var inwardNormals = false
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
        
        // TODO: buffer allocator
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        return MDLMesh.newIcosahedronWithRadius(self.radius,
                                                inwardNormals: self.inwardNormals,
                                                allocator: self.allocator)
    }
}

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

public protocol MeshGenerator {
    //    func flattenMap(vertexMap: OrderedDictionary<Int, [Int]>) -> [Int]
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLMesh
    
//    func getVertices() -> [float4]
//    func getColorCoords() -> [float4]
//    func getTexCoords() -> [float4]
//    func getTriangleVertexMap() -> [[Int]]
//    func getFaceTriangleMap() -> [[Int]]

    init(container: Container, args: [String: GeneratorArg])
}


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

public class BoxMeshGen: MeshGenerator {
    // TODO: defaults?
    
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
        
        //+ newBoxWithDimensions:segments:geometryType:inwardNormals:allocator:
        
        return MDLMesh()
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
        
        return MDLMesh()
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

public class PlaneDimMeshGen: MeshGenerator {
    public var dimensions = float2(10.0, 10.0)
    public var segments = int2(10, 10)
    public var geometryType: MDLGeometryType = .TypeTriangles
    public weak var allocator: MDLMeshBufferAllocator?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
//        return MDLMesh()
        //+ return MDLMesh.newPlaneWithDimensions(self.dimensions, segments: self.segments, geometryType: self.geometryType, allocator: self.allocator)
        
        return MDLMesh()
    }
}

public class IcosohedronMeshGen: MeshGenerator {
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
    }
    
    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
        //+ newIcosahedronWithRadius:inwardNormals:allocator:
        
        return MDLMesh()
    }
}











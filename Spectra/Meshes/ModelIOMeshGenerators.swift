////
////  MDLMeshGenerators.swift
////  
////
////  Created by David Conner on 3/4/16.
////
////
//
//import Foundation
//import Metal
//import ModelIO
//import simd
//import Swinject
//
//// TODO: how to compose various functionalities together?
//
//// Model I/O generators create meshes using a VertexDescriptor with:
//// - position: 12B
//// - normal: 12B
//// - textureCoordinates: 8B
//
//public class ModelIOMeshGenerators {
//
//    public static func loadMeshGenerators(container: Container) {
//        container.register(MeshGenerator.self, name: "ellipsoid_mesh_gen") { _ in
//            return EllipsoidMeshGen(container: container)
//        }.inObjectScope(.None)
//        container.register(MeshGenerator.self, name: "elliptical_cone_mesh_gen") { _ in
//            return EllipticalConeMeshGen(container: container)
//        }.inObjectScope(.None)
//        container.register(MeshGenerator.self, name: "cylinder_mesh_gen") { _ in
//            return CylinderMeshGen(container: container)
//        }.inObjectScope(.None)
//        container.register(MeshGenerator.self, name: "icosahedron_mesh_gen") { _ in
//            return IcosahedronMeshGen(container: container)
//        }.inObjectScope(.None)
//        container.register(MeshGenerator.self, name: "subdivision_mesh_gen") { _ in
//            return SubdivisionMeshGen(container: container)
//            }.inObjectScope(.None)
////        container.register(MeshGenerator.self, name: "box_mesh_gen") { _ in
////            return BoxMeshGen(container: container)
////        }
////        container.register(MeshGenerator.self, name: "plane_mesh_gen") { _ in
////            return PlaneMeshGen(container: container)
////        }
//    }
//}
//
//public class EllipsoidMeshGen: MeshGenerator {
//    public var radii = float3(10.0, 10.0, 10.0)
//    public var radialSegments: Int = 30
//    public var verticalSegments: Int = 10
//    public var geometryType: MDLGeometryType = .TypeTriangles
//    public var inwardNormals: Bool = false
//    public var hemisphere: Bool = false
//    
//    // TODO: should user be able to attach a buffer allocator to the instance?
//    // - allowing both this and accessing allocators from the container may complicate the interface
//    // - yet, accessing everything from a single container means that one giant D/I container needs to be passed around (very bad, when parallelism is needed)
//    
//    // NOTE: another option would be to pass around a (ContainerMap, ResourceInjectionClosure) tuple
//    // typealias ContainerMap = [String: Container]
//    // typealias ResourceInjectionClosure = (ContainerMap) -> [String: AnyObject]
//    
//    public weak var allocator: MDLMeshBufferAllocator?
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container, args: args)
//    }
//    
//    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
//        if let radii = args["radii"] {
//            self.radii = SpectraSimd.parseFloat3(radii.value)
//        }
//        if let radialSegments = args["radial_segments"] {
//            self.radialSegments = Int(radialSegments.value)!
//        }
//        if let verticalSegments = args["vertical_segments"] {
//            self.verticalSegments = Int(verticalSegments.value)!
//        }
//        if let geoType = args["geometry_type"] {
//            let enumVal = container.resolve(SpectraEnum.self, name: "mdlGeometryType")!.getValue(geoType.value)
//            self.geometryType = MDLGeometryType(rawValue: Int(enumVal))!
//        }
//        if let inwardNormals = args["inward_normals"] {
//            let valAsBool = NSString(string: inwardNormals.value).boolValue
//            self.inwardNormals = valAsBool
//        }
//        if let hemisphere = args["hemisphere"] {
//            let valAsBool = NSString(string: hemisphere.value).boolValue
//            self.hemisphere = valAsBool
//        }
//        
//        // TODO: buffer allocator
//    }
//    
//    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
//        // TODO: merge arguments for mesh generators
//        
//        return MDLMesh.newEllipsoidWithRadii(self.radii,
//            radialSegments: self.radialSegments,
//            verticalSegments: self.verticalSegments,
//            geometryType: self.geometryType,
//            inwardNormals: self.inwardNormals,
//            hemisphere: self.hemisphere,
//            allocator: allocator)
//    }
//    
//    public func copy(container: Container) -> MeshGenerator {
//        
//        let cp = EllipsoidMeshGen(container: container)
//        cp.radii = self.radii
//        cp.radialSegments = self.radialSegments
//        cp.verticalSegments = self.verticalSegments
//        cp.geometryType = self.geometryType
//        cp.inwardNormals = self.inwardNormals
//        cp.hemisphere = self.hemisphere
//        // buffer allocator
//        
//        return cp
//    }
//}
//
//public class EllipticalConeMeshGen: MeshGenerator {
//    public var height: Float = 10.0
//    public var radii: float2 = float2(10.0, 10.0)
//    public var radialSegments: Int = 30
//    public var verticalSegments: Int = 10
//    public var geometryType: MDLGeometryType = .TypeTriangles
//    public var inwardNormals = false
//    public weak var allocator: MDLMeshBufferAllocator?
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container, args: args)
//    }
//    
//    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
//        if let height = args["height"] {
//            self.height = Float(height.value)!
//        }
//        if let radii = args["radii"] {
//            self.radii = SpectraSimd.parseFloat2(radii.value)
//        }
//        if let radialSegments = args["radial_segments"] {
//            self.radialSegments = Int(radialSegments.value)!
//        }
//        if let verticalSegments = args["vertical_segments"] {
//            self.verticalSegments = Int(verticalSegments.value)!
//        }
//        if let geoType = args["geometry_type"] {
//            let enumVal = container.resolve(SpectraEnum.self, name: "mdlGeometryType")!.getValue(geoType.value)
//            self.geometryType = MDLGeometryType(rawValue: Int(enumVal))!
//        }
//        if let inwardNormals = args["inward_normals"] {
//            let valAsBool = NSString(string: inwardNormals.value).boolValue
//            self.inwardNormals = valAsBool
//        }
//        
//        // TODO: buffer allocator
//    }
//    
//    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
//        
//        return MDLMesh.newEllipticalConeWithHeight(self.height,
//            radii: self.radii,
//            radialSegments: self.radialSegments,
//            verticalSegments: self.verticalSegments,
//            geometryType: .TypeTriangles,
//            inwardNormals: self.inwardNormals,
//            allocator: nil)
//    }
//    
//    public func copy(container: Container) -> MeshGenerator {
//        
//        let cp = EllipticalConeMeshGen(container: container)
//        cp.height = self.height
//        cp.radii = self.radii
//        cp.radialSegments = self.radialSegments
//        cp.verticalSegments = self.verticalSegments
//        cp.geometryType = self.geometryType
//        cp.inwardNormals = self.inwardNormals
//        // buffer allocator
//        
//        return cp
//    }
//}
//
//public class CylinderMeshGen: MeshGenerator {
//    public var height: Float = 10.0
//    public var radii = float2(10.0, 10.0)
//    public var radialSegments: Int = 30
//    public var verticalSegments: Int = 10
//    public var geometryType: MDLGeometryType = .TypeTriangles
//    public var inwardNormals = false
//    public weak var allocator: MDLMeshBufferAllocator?
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container, args: args)
//    }
//    
//    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
//        if let height = args["height"] {
//            self.height = Float(height.value)!
//        }
//        if let radii = args["radii"] {
//            self.radii = SpectraSimd.parseFloat2(radii.value)
//        }
//        if let radialSegments = args["radial_segments"] {
//            self.radialSegments = Int(radialSegments.value)!
//        }
//        if let verticalSegments = args["vertical_segments"] {
//            self.verticalSegments = Int(verticalSegments.value)!
//        }
//        if let geoType = args["geometry_type"] {
//            let enumVal = container.resolve(SpectraEnum.self, name: "mdlGeometryType")!.getValue(geoType.value)
//            self.geometryType = MDLGeometryType(rawValue: Int(enumVal))!
//        }
//        if let inwardNormals = args["inward_normals"] {
//            let valAsBool = NSString(string: inwardNormals.value).boolValue
//            self.inwardNormals = valAsBool
//        }
//        
//        // TODO: buffer allocator
//    }
//    
//    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
//        return MDLMesh.newCylinderWithHeight(self.height,
//            radii: self.radii,
//            radialSegments: self.radialSegments,
//            verticalSegments: self.verticalSegments,
//            geometryType: .TypeTriangles,
//            inwardNormals: self.inwardNormals,
//            allocator: self.allocator)
//    }
//    
//    public func copy(container: Container) -> MeshGenerator {
//        let cp = CylinderMeshGen(container: container)
//
//        cp.height = self.height
//        cp.radii = self.radii
//        cp.radialSegments = self.radialSegments
//        cp.verticalSegments = self.verticalSegments
//        cp.geometryType = self.geometryType
//        cp.inwardNormals = self.inwardNormals
//        // allocator
//
//        return cp
//    }
//}
//
//public class IcosahedronMeshGen: MeshGenerator {
//    public var radius: Float = 10.0
//    public var inwardNormals = false
//    public weak var allocator: MDLMeshBufferAllocator?
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container, args: args)
//        // TODO: buffer allocator
//    }
//    
//    public func processArgs(container: Container, args: [String : GeneratorArg] = [:]) {
//        if let radius = args["radius"] {
//            self.radius = Float(radius.value)!
//        }
//        if let inwardNormals = args["inward_normals"] {
//            let valAsBool = NSString(string: inwardNormals.value).boolValue
//            self.inwardNormals = valAsBool
//        }
//    }
//    
//    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
//        return MDLMesh.newIcosahedronWithRadius(self.radius,
//                                                inwardNormals: self.inwardNormals,
//                                                allocator: self.allocator)
//    }
//    
//    public func copy(container: Container) -> MeshGenerator {
//        let cp = IcosahedronMeshGen(container: container)
//        
//        cp.radius = self.radius
//        cp.inwardNormals = self.inwardNormals
//        // allocator
//        
//        return cp
//    }
//}
//
//public class SubdivisionMeshGen: MeshGenerator {
//    // NOTE: because copying MDLMesh's and other objects is expensive & complicated
//    // - users should only resolve these objects in the generate() method
//    // - and users should not store them on the MeshGenerator
//    // - or, users should take care when implementing the copy() method
//    
//    public var meshRef: String?
//    public var submeshIndex: Int = 0
//    public var subdivisionLevels: Int = 1
//    public weak var allocator: MDLMeshBufferAllocator?
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container, args: args)
//    }
//    
//    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
//        if let meshRef = args["mesh_ref"] {
//            self.meshRef = meshRef.value
//        }
//        if let submeshIndex = args["submesh_index"] {
//            self.submeshIndex = Int(submeshIndex.value)!
//        }
//        if let subdivisionLevels = args["subdivision_levels"] {
//            self.subdivisionLevels = Int(subdivisionLevels.value)!
//        }
//    }
//    
//    public func generate(container: Container, args: [String : GeneratorArg]) -> MDLMesh {
//        let mesh = container.resolve(MDLMesh.self, name: meshRef!)!
//        
//        return MDLMesh.newSubdividedMesh(mesh,
//                                         submeshIndex: self.submeshIndex,
//                                         subdivisionLevels: self.subdivisionLevels)!
//    }
//    
//    public func copy(container: Container) -> MeshGenerator {
//        let cp = SubdivisionMeshGen(container: container)
//        cp.meshRef = self.meshRef
//        cp.submeshIndex = self.submeshIndex
//        cp.subdivisionLevels = self.subdivisionLevels
//        return cp
//    }
//}
//
//
//// BoxMeshGen & PlaneMeshGen 
//// - functions for these haven't been implemented in Model I/O
//
////public class BoxMeshGen: MeshGenerator {
////    public var dimensions: float3 = [10.0, 10.0, 10.0]
////    public var segments: int3 = [10, 10, 10] // vector_uint3 ??
////    public var geometryType: MDLGeometryType = .TypeTriangles
////    public var inwardNormals: Bool = false
////    public weak var allocator: MDLMeshBufferAllocator?
////    
////    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
////        
////        if let dimensions = args["dimensions"] {
////            self.dimensions = SpectraSimd.parseFloat3(dimensions.value)
////        }
////        if let segments = args["segments"] {
////            self.segments = SpectraSimd.parseInt3(segments.value)
////        }
////        if let geoType = args["geometry_type"] {
////            // self.geometryType = .TypeTriangles
////        }
////        if let inwardNormals = args["inward_normals"] {
////            let valAsBool = NSString(string: inwardNormals.value).boolValue
////            self.inwardNormals = valAsBool
////        }
////        //TODO: buffer allocator
////    }
////    
////    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLMesh {
////        return MDLMesh()
////        
////        // TODO: removed from Model I/O API?  It's still accessible in source
////        //        return MDLMesh.newBoxWithDimensions(self.dimensions,
////        //                                            segments: self.segments,
////        //                                            geometryType: self.geometryType,
////        //                                            inwardNormals: self.inwardNormals,
////        //                                            allocator: allocator)
////    }
////    
////    public func copy(container: Container) -> BoxMeshGen {
////        let cp = BoxMeshGen(container: container)
////        // TODO: implement copy()
////        return cp
////    }
////}
////
////public class PlaneMeshGen: MeshGenerator {
////    public var dimensions: float2 = float2(10.0, 10.0)
////    public var segments: int2 = int2(10, 10)
////    public var geometryType: MDLGeometryType = .TypeTriangles
////    public weak var allocator: MDLMeshBufferAllocator?
////    
////    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
////        if let dimensions = args["dimensions"] {
////            self.dimensions = SpectraSimd.parseFloat2(dimensions.value)
////        }
////        
////        if let segments = args["segments"] {
////            self.segments = SpectraSimd.parseInt2(segments.value)
////        }
////        
////        if let geometryType = args["geometry_type"] {
////            self.geometryType = .TypeTriangles
////        }
////        
////        // TODO: buffer allocator
////    }
////    
////    public func generate(container: Container, args: [String : GeneratorArg] = [:]) -> MDLMesh {
////        return MDLMesh()
////        //        return MDLMesh.newPlaneWithDimensions(self.dimensions,
////        //                                              segments: self.segments,
////        //                                              geometryType: self.geometryType,
////        //                                              allocator: self.allocator)
////    }
////}

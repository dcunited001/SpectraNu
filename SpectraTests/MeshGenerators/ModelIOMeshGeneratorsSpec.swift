//
//  MDLMeshGeneratorSpecs.swift
//  
//
//  Created by David Conner on 3/4/16.
//
//

@testable import Spectra
import Quick
import Nimble
import Swinject
import MetalKit
import simd

class ModelIOMeshGeneratorsSharedExamples: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("A Model I/O Mesh Generator") {
            it("foos") {
                
            }
        }
    }
}

class ModelIOMeshGeneratorsSpec: QuickSpec {
    
    override func spec() {
        describe("must foo") {
            it("to bar") {
                
            }
        }

//        let parser = Container()
//        
//        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
//        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
//        spectraEnumXSD.parseEnumTypes(parser)
//        
//        let testBundle = NSBundle(forClass: ModelIOMeshGeneratorsSpec.self)
//        let xmlData: NSData = SpectraXML.readXML(testBundle, filename: "ModelIOMeshGeneratorsSpec")
//        let assetContainer = Container(parent: parser)
//        
//        ModelIOMeshGenerators.loadMeshGenerators(assetContainer)
//        
//        SpectraXML.initParser(parser)
//        let spectraXML = SpectraXML(parser: parser, data: xmlData)
//        spectraXML.parse(assetContainer, options: [:])
//        
//        let device = MTLCreateSystemDefaultDevice()!
//        let allocator = MTKMeshBufferAllocator(device: device)
//        
//        describe("EllipsoidMeshGen") {
//            let ellipsoid = assetContainer.resolve(MeshGenerator.self, name: "ellipsoid_mesh_gen") as! EllipsoidMeshGen
//            let ellipsoid2 = assetContainer.resolve(MeshGenerator.self, name: "ellipsoid_mesh_gen2") as! EllipsoidMeshGen
//            
//            ellipsoid.allocator = allocator
//            ellipsoid2.allocator = allocator
//            
//            it("can extend the model i/o mesh generators") {
//                expect(SpectraSimd.compareFloat3(ellipsoid.radii, with: float3(10, 10, 10))).to(beTrue())
//                expect(ellipsoid.radialSegments) == 30
//                expect(ellipsoid.verticalSegments) == 10
//                expect(SpectraSimd.compareFloat3(ellipsoid2.radii, with: float3(5, 5, 5))).to(beTrue())
//                expect(ellipsoid2.radialSegments) == 5
//                expect(ellipsoid2.verticalSegments) == 5
//            }
//            
//            it("can generate a MDLMesh with the appropriate vertices & submeshes") {
//                let ellipsoidMesh = ellipsoid.generate(assetContainer)
//                let ellipsoidMesh2: MDLMesh = ellipsoid2.generate(assetContainer)
//                
//                expect(ellipsoidMesh.vertexCount) == 281
//                expect(ellipsoidMesh.submeshes.count) == 1
//                expect(ellipsoidMesh.vertexBuffers.count) == 1
//                
//                expect(ellipsoidMesh.vertexDescriptor.attributes[0].name) == "position"
//                expect(ellipsoidMesh.vertexDescriptor.attributes[0].offset) == 0
//                expect(ellipsoidMesh.vertexDescriptor.attributes[1].name) == "normal"
//                expect(ellipsoidMesh.vertexDescriptor.attributes[1].offset) == 12
//                expect(ellipsoidMesh.vertexDescriptor.attributes[2].name) == "textureCoordinate"
//                expect(ellipsoidMesh.vertexDescriptor.attributes[2].offset) == 24
//                
//                expect(ellipsoidMesh2.vertexCount) == 26
//                expect(ellipsoidMesh.submeshes.count) == 1
//                expect(ellipsoidMesh.vertexBuffers.count) == 1
//            }
//        }
//        
//        describe("EllipticalConeMeshGen") {
//            let coneGen = assetContainer.resolve(MeshGenerator.self, name: "elliptical_cone_mesh_gen2") as! EllipticalConeMeshGen
//            
//            it("can extend the model i/o mesh generators") {
//                expect(coneGen.height) == 100.0
//                expect(SpectraSimd.compareFloat2(coneGen.radii, with: float2(5, 5))).to(beTrue())
//                expect(coneGen.radialSegments) == 5
//                expect(coneGen.verticalSegments) == 5
//            }
//            
//            it("can generate a MDLMesh with the appropriate vertices & submeshes") {
//                let cone = assetContainer.resolve(MDLMesh.self, name: "elliptical_cone_mesh2")!
//                
//                expect(cone.submeshes.count) == 1
//                expect(cone.vertexBuffers.count) == 1
//                expect(cone.vertexCount) == 43
//            }
//
//        }
//        
//        describe("CylinderMeshGen") {
//            let cylinderGen = assetContainer.resolve(MeshGenerator.self, name: "cylinder_mesh_gen") as! CylinderMeshGen
//            let cylinderGen2 = assetContainer.resolve(MeshGenerator.self, name: "cylinder_mesh_gen2") as! CylinderMeshGen
//            
//            it("can extend the model i/o mesh generators") {
//                expect(cylinderGen2.height) == 100.0
//                expect(SpectraSimd.compareFloat2(cylinderGen2.radii, with: float2(5,5))).to(beTrue())
//                expect(cylinderGen2.radialSegments) == 5
//                expect(cylinderGen2.verticalSegments) == 5
//            }
//            
//            it("allows the geometry type to be updated") {
//                print(cylinderGen2.geometryType.rawValue)
//                expect(cylinderGen2.geometryType) == MDLGeometryType.TypeQuads
//            }
//        }
//
//        describe("IcosahedronMeshGen") {
//            let icosahedronGen = assetContainer.resolve(MeshGenerator.self, name: "icosahedron_mesh_gen") as! IcosahedronMeshGen
//            let icosahedronGen2 = assetContainer.resolve(MeshGenerator.self, name: "icosahedron_mesh_gen2") as! IcosahedronMeshGen
//
//            it("can extend the model i/o mesh generators") {
//                expect(icosahedronGen2.radius) == 100
//            }
//        }
//
//        describe("SubdivisionMeshGen") {
//            let subdivide = assetContainer.resolve(MeshGenerator.self, name: "subdivision_mesh_gen") as! SubdivisionMeshGen
//            let subdivide2 = assetContainer.resolve(MeshGenerator.self, name: "subdivision_mesh_gen2") as! SubdivisionMeshGen
//            
//            it("can extend the model i/o mesh generators") {
//                expect(subdivide2.meshRef) == "elliptical_cone_mesh3"
//            }
//            
//            it("subdivides the existing mesh, modifying it in place") {
//                let subdividedCone = assetContainer.resolve(MDLMesh.self, name: "elliptical_cone_mesh3")!
//                
//                expect(subdividedCone.vertexCount) == 194
//                expect(subdividedCone.vertexBuffers.count) == 1
//                expect(subdividedCone.submeshes.count) == 1
//            }
//        }
//    }
//}
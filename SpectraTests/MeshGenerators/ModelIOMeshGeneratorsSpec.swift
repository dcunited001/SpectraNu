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
        let parsedEnums = Container()
        
        let spectraEnumXSD = SpectraXSD.readXSD("SpectraEnums")!
        let spectraXSD = SpectraXSD()
        spectraXSD.parseXSD(spectraEnumXSD, container: parsedEnums)
        let parsedNodes = Container(parent: parsedEnums)

        let testBundle = NSBundle(forClass: ModelIOMeshGeneratorsSpec.self)
        let sp = SpectraParser(nodes: parsedNodes)
        let spectraXML = SpectraParser.readXML(testBundle, filename: "ModelIOMeshGeneratorsSpec", bundleResourceName: nil)!
        
        ModelIOMeshGenerators.loadMeshGenerators(sp.nodes)
        sp.parseXML(spectraXML)
        
        let device = MTLCreateSystemDefaultDevice()!
        let allocator = MTKMeshBufferAllocator(device: device)
        
        describe("EllipsoidMeshGen") {
            // gengen, yeh it sounds redundant, i know.  
            // - but this abstraction allows heavy resources like meshes to be attached to mesh generators that persist
//            let gen = sp.getMeshGenerator("ellipsoid_mesh_gen")!.generate(["models": sp.nodes]) as! EllipsoidMeshGen
            let gen2 = sp.getMeshGenerator("ellipsoid_mesh_gen2")!.generate(["models": sp.nodes]) as! EllipsoidMeshGen
            
            it("can extend the model i/o mesh generators") {
//                expect(SpectraSimd.compareFloat3(gen.radii, with: float3(10, 10, 10))).to(beTrue())
//                expect(gen.radialSegments) == 30
//                expect(gen.verticalSegments) == 10
                expect(SpectraSimd.compareFloat3(gen2.radii, with: float3(5, 5, 5))).to(beTrue())
                expect(gen2.radialSegments) == 5
                expect(gen2.verticalSegments) == 5
            }
            
            it("can generate a MDLMesh with the appropriate vertices & submeshes") {
//                let mesh = gen.generate(sp.nodes)
                let mesh2: MDLMesh = gen2.generate(sp.nodes)
                
//                expect(mesh.vertexCount) == 281
//                expect(mesh.submeshes.count) == 1
//                expect(mesh.vertexBuffers.count) == 1
//                
//                expect(mesh.vertexDescriptor.attributes[0].name) == "position"
//                expect(mesh.vertexDescriptor.attributes[0].offset) == 0
//                expect(mesh.vertexDescriptor.attributes[1].name) == "normal"
//                expect(mesh.vertexDescriptor.attributes[1].offset) == 12
//                expect(mesh.vertexDescriptor.attributes[2].name) == "textureCoordinate"
//                expect(mesh.vertexDescriptor.attributes[2].offset) == 24
//                
//                expect(mesh2.vertexCount) == 26
//                expect(mesh.submeshes.count) == 1
//                expect(mesh.vertexBuffers.count) == 1
            }
        }
        
        describe("EllipticalConeMeshGen") {
            let coneGen = sp.getMeshGenerator("elliptical_cone_mesh_gen2")!.generate(["models": sp.nodes]) as! EllipticalConeMeshGen
            
            it("can extend the model i/o mesh generators") {
                expect(coneGen.height) == 100.0
                expect(SpectraSimd.compareFloat2(coneGen.radii, with: float2(5, 5))).to(beTrue())
                expect(coneGen.radialSegments) == 5
                expect(coneGen.verticalSegments) == 5
            }
            
            it("can generate a MDLMesh with the appropriate vertices & submeshes") {
                let cone = sp.getMesh("elliptical_cone_mesh2")!.generate(["models": sp.nodes]) as! MDLMesh
                expect(cone.submeshes.count) == 1
                expect(cone.vertexBuffers.count) == 1
                expect(cone.vertexCount) == 43
            }

        }
        
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
    }
}
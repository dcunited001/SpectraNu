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

class ModelIOMeshGeneratorsSpec: QuickSpec {
    
    func containerGet<T>(container: Container, key: String) -> T? {
        return container.resolve(T.self, name: key)
    }
    
    override func spec() {
        let parser = Container()
        
        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
        spectraEnumXSD.parseEnumTypes(parser)
        
        let testBundle = NSBundle(forClass: ModelIOMeshGeneratorsSpec.self)
        let xmlData: NSData = SpectraXML.readXML(testBundle, filename: "ModelIOMeshGeneratorsSpec")
        let assetContainer = Container(parent: parser)
        
        SpectraXML.initParser(parser)
        let spectraXML = SpectraXML(parser: parser, data: xmlData)
        spectraXML.parse(assetContainer, options: [:])
        
        describe("BoxMeshGen", flags: ["pending": true]) {
            // PENDING: model i/o function not recognized
            
            let box: MeshGenerator = self.containerGet(assetContainer, key: "box_mesh_gen")!
            let box2: MeshGenerator = self.containerGet(assetContainer, key: "box_mesh_gen2")!
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("EllipsoidMeshGen") {
            let ellisoid: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoid_mesh_gen")!
            let ellisoid2: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoid_mesh_gen2")!
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("EllipticalConeMeshGen") {
            let ellipticCone: MeshGenerator = self.containerGet(assetContainer, key: "elliptic_cone_mesh_gen")!
            let ellipticCone2: MeshGenerator = self.containerGet(assetContainer, key: "elliptic_coner_mesh_gen2")!
            
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("CylinderMeshGen") {
            let cylinder: MeshGenerator = self.containerGet(assetContainer, key: "cylinder_mesh_gen")!
            let cylinder2: MeshGenerator = self.containerGet(assetContainer, key: "cylinder_mesh_gen2")!
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("PlaneDimMeshGen", flags: ["pending": true]) {
            // PENDING: model i/o function not recognized
            
            let plane: MeshGenerator = self.containerGet(assetContainer, key: "plane_mesh_gen")!
            let plane2: MeshGenerator = self.containerGet(assetContainer, key: "plane_mesh_gen2")!
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("IcosahedronMeshGen") {
            let icosahedron: MeshGenerator = self.containerGet(assetContainer, key: "icosahedron_mesh_gen")!
            let icosahedron2: MeshGenerator = self.containerGet(assetContainer, key: "icosahedron_mesh_gen2")!
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
    }
}
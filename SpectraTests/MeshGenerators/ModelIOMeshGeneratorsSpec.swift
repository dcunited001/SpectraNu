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
        
        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "ModelIOMeshGeneratorSpecs")
        let assetContainer = Container(parent: parser)
        
        SpectraXML.initParser(parser)
        let spectraXML = SpectraXML(parser: parser, data: xmlData)
        spectraXML.parse(assetContainer, options: [:])
        
        describe("BoxMeshGen") {
            let box: MeshGenerator = self.containerGet(assetContainer, key: "boxMeshGen")
            let box2: MeshGenerator = self.containerGet(assetContainer, key: "boxMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("EllipsoidMeshGen") {
            let ellisoid: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoidMeshGen")
            let ellisoid2: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoidMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("EllipticalConeMeshGen") {
            let ellipticCone: MeshGenerator = self.containerGet(assetContainer, key: "ellipticConeMeshGen")
            let ellipticCone2: MeshGenerator = self.containerGet(assetContainer, key: "ellipticConeMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("CylinderMeshGen") {
            let cylinder: MeshGenerator = self.containerGet(assetContainer, key: "cylinderMeshGen")
            let cylinder2: MeshGenerator = self.containerGet(assetContainer, key: "cylinderMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("PlaneDimMeshGen") {
            let plane: MeshGenerator = self.containerGet(assetContainer, key: "planeMeshGen")
            let plane2: MeshGenerator = self.containerGet(assetContainer, key: "planeMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
        describe("IcosohedronMeshGen") {
            let icosohedron: MeshGenerator = self.containerGet(assetContainer, key: "icosohedronMeshGen")
            let icosohedron2: MeshGenerator = self.containerGet(assetContainer, key: "icosohedronMeshGen2")
            
            it("provides the basic model i/o mesh generators") {
                
            }
            
            it("allows the for the extension of the basic mesh generator") {
                
            }
        }
        
    }
}
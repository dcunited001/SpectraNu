//
//  MDLMeshGeneratorSpecs.swift
//  
//
//  Created by David Conner on 3/4/16.
//
//

import Foundation

class ModelIOMeshGeneratorSpecs: QuickSpec {
    
    func containerGet<T>(container: Container, key: String) -> T? {
        return container.resolve(T.self, name: key)
    }
    
    override func spec() {
        // read xsd
        // read xml
        // ...
        
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
        
        let box: MeshGenerator = self.containerGet(assetContainer, key: "boxMeshGen")
        let box2: MeshGenerator = self.containerGet(assetContainer, key: "boxMeshGen2")
        let ellisoid: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoidMeshGen")
        let ellisoid2: MeshGenerator = self.containerGet(assetContainer, key: "ellipsoidMeshGen2")
        let ellipticCone: MeshGenerator = self.containerGet(assetContainer, key: "ellipticConeMeshGen")
        let ellipticCone2: MeshGenerator = self.containerGet(assetContainer, key: "ellipticConeMeshGen2")
        let cylinder: MeshGenerator = self.containerGet(assetContainer, key: "cylinderMeshGen")
        let cylinder2: MeshGenerator = self.containerGet(assetContainer, key: "cylinderMeshGen2")
        let plane: MeshGenerator = self.containerGet(assetContainer, key: "planeMeshGen")
        let plane2: MeshGenerator = self.containerGet(assetContainer, key: "planeMeshGen2")
        let icosohedron: MeshGenerator = self.containerGet(assetContainer, key: "icosohedronMeshGen")
        let icosohedron2: MeshGenerator = self.containerGet(assetContainer, key: "icosohedronMeshGen2")

        describe("default mesh generators") {
            it("provides all the model i/o mesh generators with no config required") {
                
            }
        }
        
        describe("BoxMeshGen") {
            
        }
        
        describe("EllipsoidMeshGen") {
        }
        
        describe("EllipticalConeMeshGen") {
        }
        
        describe("CylinderMeshGen") {
            
        }
        
        describe("PlaneDimMeshGen") {
        }
        
        describe("IcosohedronMeshGen") {
            
        }
        
    }
}
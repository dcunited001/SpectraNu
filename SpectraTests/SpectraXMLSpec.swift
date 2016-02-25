//
//  SpectraXMLSpec.swift
//  
//
//  Created by David Conner on 2/23/16.
//
//

import Foundation
import Quick
import Nimble
import ModelIO
import Fuzi
import Spectra
import simd

class SpectraXMLSpec: QuickSpec {
    
    override func spec() {
        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "SceneGraphXMLTest")
        let spectraXML = SpectraXML(data: xmlData)
        
        // TODO: move this to a new file?
        describe("parser can register new D/I handlers for XML tags") {
            
        }
        
        describe("parser can also register custom types to return") {
            it("allows resolution of SpectraXMLNodeType with custom types") {
                let notAnEnumCase = SpectraXMLNodeType(rawValue: "not-a-type")
                expect(notAnEnumCase!.rawValue) == "not-a-type"
            }
        }
        
        describe("vertex-attribute") {
            let attrPosition = MDLVertexAttribute(name: MDLVertexAttributePosition, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 0)
            let attrColor = MDLVertexAttribute(name: MDLVertexAttributeColor, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 1)
            let attrTexture = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: MDLVertexFormat.Float2, offset: 0, bufferIndex: 2)
            let attrAnisotropy = MDLVertexAttribute(name: MDLVertexAttributeAnisotropy, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 3)
            it("can parse vertex attribute nodes") {
                
            }
        }
        
        describe("vertex-descriptor") {
            it("can parse vertex descriptor with references to vertex attributes") {
                
            }
            
            it("can parse vertex descriptor, mixing references with new attributes") {
                
            }
            
            it("can parse vertex descriptor to create either array-of-struct or struct-of-array indexing") {
                
            }
        }
        
        // TODO: convert from VertexDescriptor with array-of-struct to struct-of-array indexing
        // TODO: convert MDLVertexDescriptor <=> MTLVertexDescriptor
        
        describe("world-view") {
            it("can parse world view nodes") {
                
            }
        }
        
        describe("camera") {
            it("can parse camera nodes") {
                
            }
        }
        
        describe("perspective") {
            it("can parse perspective nodes") {
                
            }
        }
    }
}



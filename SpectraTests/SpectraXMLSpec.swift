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
import Swinject
import simd

class SpectraXMLSpec: QuickSpec {
    
    func containerGet<T>(container: Container, key: String) -> T? {
        return container.resolve(T.self, name: key)
    }
    
    override func spec() {
        let parser = Container()
        
        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
        spectraEnumXSD.parseEnumTypes(parser)
        
        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "SpectraXMLTest")
        let assetContainer = Container(parent: parser)
        
        let spectraXML = SpectraXML(parser: parser, data: xmlData)
        
        // TODO: move this to a new file?
        describe("SpectraXML: main parser") {
            describe("parser can register new D/I handlers for XML tags") {
                
            }
            
            describe("parser can also register custom types to return") {
                it("allows resolution of SpectraXMLNodeType with custom types") {
                    
                }
            }
        }
        
        describe("SpectraXMLNodeTuple") {
            it("can recursively resolve dependencies using (construct, meta)") {
                
            }
        }
        
        describe("vertex-attribute") {
            let attrPos: MDLVertexAttribute = self.containerGet(assetContainer, key: "pos_float4")!
            let attrTex: MDLVertexAttribute = self.containerGet(assetContainer, key: "tex_float2")!
            let attrRgb: MDLVertexAttribute = self.containerGet(assetContainer, key: "rgb_float4")!
            let attrRgbInt: MDLVertexAttribute = self.containerGet(assetContainer, key: "rgb_int4")!
            let attrAniso: MDLVertexAttribute = self.containerGet(assetContainer, key: "aniso_float4")!
            let attrCustomLabel: MDLVertexAttribute = self.containerGet(assetContainer, key: "test_custom_label")!
            let attrImmutable: MDLVertexAttribute = self.containerGet(assetContainer, key: "test_immutable")!
            
            it("can parse vertex attribute nodes") {
                // for now, deferring assignment of bufferIndex and offset to MDLVertexDescriptor
                expect(attrPos.name) == MDLVertexAttributePosition
                expect(attrTex.name) == MDLVertexAttributeTextureCoordinate
                expect(attrRgb.name) == MDLVertexAttributeColor
                expect(attrAniso.name) == MDLVertexAttributeAnisotropy
            }
            
            it("can create attributes with custom labels") {
                expect(attrCustomLabel.name) == "custom"
            }
            
            it("reads the correct MDLVertexFormat") {
                expect(attrPos.format) == MDLVertexFormat.Float4
                expect(attrTex.format) == MDLVertexFormat.Float2
                expect(attrRgb.format) == MDLVertexFormat.Float4
                expect(attrRgbInt.format) == MDLVertexFormat.Int4
                expect(attrAniso.format) == MDLVertexFormat.Float4
                expect(attrImmutable.format) == MDLVertexFormat.Int
            }
            
            it("retains immutable copies which are not changed") {
                let origIndex = attrImmutable.bufferIndex
                attrImmutable.bufferIndex = origIndex + 1
                let attrImmutable2: MDLVertexAttribute = self.containerGet(assetContainer, key: "test_immutable")!
                expect(attrImmutable.bufferIndex) != attrImmutable2.bufferIndex
                expect(attrImmutable2.bufferIndex) == origIndex
                
                // just want to see how default values are initialized
                let origAttrPosIndex = attrPos.bufferIndex
                attrPos.bufferIndex = origAttrPosIndex + 1
                
                let attrPos2: MDLVertexAttribute = self.containerGet(assetContainer, key: "pos_float_4")!
                expect(attrPos.bufferIndex) != attrPos2.bufferIndex
                expect(attrPos2.bufferIndex) == origAttrPosIndex
            }
        }
        
        describe("vertex-descriptor") {
            it("can parse vertex descriptor with references to vertex attributes") {
                let vertDesc = MDLVertexDescriptor()
                // TODO: fetch from D/I
            }
            
            it("can parse with packed-layout to create array-of-struct indexing") {
                
            }
            
            it("can parse without packed-layout to create struct-of-array indexing") {
                
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



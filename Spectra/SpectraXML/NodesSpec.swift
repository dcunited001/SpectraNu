//
//  NodesSpec.swift
//  
//
//  Created by David Conner on 3/10/16.
//
//

import Foundation
import Quick
import Nimble

@testable import Spectra
import Fuzi
import Swinject
import ModelIO

class SpectraXMLNodesSpec: QuickSpec {
    override func spec() {
        
        let parsedEnums = Container()
        
        let spectraEnumXSD = SpectraXSD.readXSD("SpectraEnums")!
        let spectraXSD = SpectraXSD()
        spectraXSD.parseXSD(spectraEnumXSD, container: parsedEnums)
        let parsedNodes = Container(parent: parsedEnums)
        
        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
        let spectraParser = SpectraParser(nodes: parsedNodes)
        let spectraXML = SpectraParser.readXML(testBundle, filename: "SpectraXMLSpec", bundleResourceName: nil)!
        spectraParser.parseXML(spectraXML)
        
        describe("VertexAttribute") {
            let attrPos = spectraParser.getVertexAttribute("pos_float4")!
            let attrTex = spectraParser.getVertexAttribute("tex_float2")!
            let attrRgb = spectraParser.getVertexAttribute("rgb_float4")!
            let attrRgbInt = spectraParser.getVertexAttribute("rgb_int4")!
            let attrAniso = spectraParser.getVertexAttribute("aniso_float4")!
            let attrCustomLabel = spectraParser.getVertexAttribute("test_custom_label")!
            let attrImmutable = spectraParser.getVertexAttribute("test_immutable")!
            
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
                let attrImmutable2 = spectraParser.getVertexAttribute("test_immutable")!
                expect(attrImmutable.bufferIndex) != attrImmutable2.bufferIndex
                expect(attrImmutable2.bufferIndex) == origIndex
            }
        }
        
        describe("VertexDescriptor") {
            
        }
        
        describe("Transform") {
            
        }
    }
}
//
//  NodesSpec.swift
//  
//
//  Created by David Conner on 3/10/16.
//
//

@testable import Spectra
import Quick
import Nimble
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

            // TODO: decide on whether copies should be immutable
//            it("retains immutable copies which are not changed") {
//                let origIndex = attrImmutable.bufferIndex
//                attrImmutable.bufferIndex = origIndex + 1
//                let attrImmutable2 = spectraParser.getVertexAttribute("test_immutable")!
//                expect(attrImmutable.bufferIndex) != attrImmutable2.bufferIndex
//                expect(attrImmutable2.bufferIndex) == origIndex
//            }
        }
        
        describe("vertex-descriptor") {
            let attrPos = spectraParser.getVertexAttribute("pos_float4")!
            let attrTex = spectraParser.getVertexAttribute("tex_float2")!
            let vertDescPosTex = spectraParser.getVertexDescriptor("vert_pos_tex_float")!
            let vertDescPosRgb = spectraParser.getVertexDescriptor("vert_pos_rgb_float")!

            it("can parse vertex descriptor with references to vertex attributes") {
                let pos1 = vertDescPosTex.attributes[0]
                let tex1 = vertDescPosTex.attributes[1]
                let pos2 = vertDescPosRgb.attributes[0]
                let rgb2 = vertDescPosRgb.attributes[1]

                expect(pos1.format) == MDLVertexFormat.Float4
                expect(tex1.format) == MDLVertexFormat.Float2
                expect(pos2.format) == MDLVertexFormat.Float4
                expect(rgb2.format) == MDLVertexFormat.Int4

                expect(vertDescPosTex.attributes[0].name) == "position"
                expect(vertDescPosTex.attributes[1].name) == "textureCoordinate"

                expect(vertDescPosRgb.attributes[0].name) == "position"
                expect(vertDescPosRgb.attributes[1].name) == "color"
            }

            it("can parse a descriptor with a packed array-of-struct indexing") {
                let packedDescNode = spectraParser.getVertexDescriptor("vertdesc_packed")!
                let packedDesc = packedDescNode.generate()
                
                let pos = packedDesc.attributeNamed("position")!
                let tex = packedDesc.attributeNamed("textureCoordinate")!
                let aniso = packedDesc.attributeNamed("anisotropy")!

                expect(pos.format) == MDLVertexFormat.Float4
                expect(tex.format) == MDLVertexFormat.Float2
                expect(aniso.format) == MDLVertexFormat.Float4

                expect(pos.offset) == 0
                expect(tex.offset) == 16
                expect(aniso.offset) == 24

                expect(pos.bufferIndex) == 0
                expect(tex.bufferIndex) == 0
                expect(aniso.bufferIndex) == 0
            }

            it("can parse a descriptor with an unpacked struct-of-array indexing (each attribute has a buffer)") {
                let unpackedDescNode = spectraParser.getVertexDescriptor("vertdesc_unpacked")!
                let unpackedDesc = unpackedDescNode.generate()
                
                let pos = unpackedDesc.attributeNamed("position")!
                let tex = unpackedDesc.attributeNamed("textureCoordinate")!
                let aniso = unpackedDesc.attributeNamed("anisotropy")!

                expect(pos.format) == MDLVertexFormat.Float4
                expect(tex.format) == MDLVertexFormat.Float2
                expect(aniso.format) == MDLVertexFormat.Float4

                expect(pos.offset) == 0
                expect(tex.offset) == 0
                expect(aniso.offset) == 0

                expect(pos.bufferIndex) == 0
                expect(tex.bufferIndex) == 1
                expect(aniso.bufferIndex) == 2
            }

            it("can parse a more complex layout") {
                let complexDescNode = spectraParser.getVertexDescriptor("vertdesc_complex")!
                let complexDesc = complexDescNode.generate()
                
                let pos = complexDesc.attributeNamed("position")!
                let tex = complexDesc.attributeNamed("textureCoordinate")!
                let aniso = complexDesc.attributeNamed("anisotropy")!
                let rgb = complexDesc.attributeNamed("color")!

                expect(pos.format) == MDLVertexFormat.Float4
                expect(tex.format) == MDLVertexFormat.Float2
                expect(aniso.format) == MDLVertexFormat.Float4
                expect(rgb.format) == MDLVertexFormat.Float4
                
                expect(pos.offset) == 0
                expect(tex.offset) == 0
                expect(aniso.offset) == 8
                expect(rgb.offset) == 0
                
                expect(pos.bufferIndex) == 0
                expect(tex.bufferIndex) == 1
                expect(aniso.bufferIndex) == 1
                expect(rgb.bufferIndex) == 2
            }
        }
        
        describe("Transform") {
            let xformTranslate = spectraParser.getTransform("xform_translate")!
            let xformRotate = spectraParser.getTransform("xform_rotate")!
            let xformScale = spectraParser.getTransform("xform_scale")!
            let xformShear = spectraParser.getTransform("xform_shear")!
//            let xformCompose1: MDLTransform = spectraParser.getTransform("xform_compose1")!
//            let xformCompose2: MDLTransform = spectraParser.getTransform("xform_compose2")!

            it("parses translation/rotation/scale/shear") {
                //TODO: rotation with degrees
                expect(SpectraSimd.compareFloat3(xformTranslate.translation, with: float3(10.0, 20.0, 30.0))).to(beTrue())
                expect(SpectraSimd.compareFloat3(xformRotate.rotation, with: float3(0.25, 0.50, 1.0))).to(beTrue())
                expect(SpectraSimd.compareFloat3(xformScale.scale, with: float3(2.0, 2.0, 2.0))).to(beTrue())
                expect(SpectraSimd.compareFloat3(xformShear.shear, with: float3(10.0, 10.0, 1.0))).to(beTrue())
            }

            pending("correctly composes multiple operations") {
                // check that translate/rotate/scale/shear is calculated correctly when composed
            }
        }
    }
}
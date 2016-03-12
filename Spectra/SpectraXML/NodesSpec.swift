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
        
        describe("VertexDescriptor") {
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
        
        describe("Camera") {
            let lens1 = spectraParser.getPhysicalLens("lens1")!
            let lens2 = spectraParser.getPhysicalLens("lens2")!
            let lens3 = spectraParser.getPhysicalLens("lens3")!

            let physImg1 = spectraParser.getPhysicalImagingSurface("phys_img1")!
            let physImg2 = spectraParser.getPhysicalImagingSurface("phys_img2")!

            // camera with defaults
            // camera with lens applied
            // camera with physImg applied
            // camera with lookAt applied

            let defaultCam = spectraParser.getCamera("default")!
            let cam1 = spectraParser.getCamera("cam1")!
            let cam2 = spectraParser.getCamera("cam2")!
            let cam3 = spectraParser.getCamera("cam3")!
            let cam4 = spectraParser.getCamera("cam4")!

            let defaultStereoCam = spectraParser.getStereoscopicCamera("default")!
            let stereoCam1 = spectraParser.getStereoscopicCamera("stereo_cam1")!
            let stereoCam2 = spectraParser.getStereoscopicCamera("stereo_cam2")!

            describe("PhysicalLens") {
                it("can specify Physical Lens parameters") {
                    expect(lens1.barrelDistortion) == 0.1
                    expect(lens1.fisheyeDistortion) == 0.5

                    expect(lens2.focalLength) == 77.0
                    expect(lens2.fStop) == 7.0
                    expect(lens2.maximumCircleOfConfusion) == 0.10

                    expect(lens3.apertureBladeCount) == 7
                }
            }

            describe("PhysicalImagingSurface") {
                it("can specify Physical Imaging Surface parameters") {
                    expect(physImg1.sensorVerticalAperture) == 24
                    expect(physImg1.sensorAspect) == 2.0

                    let expectedFlash = float3([0.1, 0.1, 0.1])
                    let expectedExposure = float3([1.5, 1.5, 1.5])
                    expect(SpectraSimd.compareFloat3(physImg2.flash!, with: float3([0.1, 0.1, 0.1]))).to(beTrue())
                    expect(SpectraSimd.compareFloat3(physImg2.exposure!, with: float3([1.5, 1.5, 1.5]))).to(beTrue())
                }
            }

            describe("Camera") {
                it("manages the inherited MDLObject properties") {
                    // transform
                    // parent
                }

                it("loads default values") {
                    expect(defaultCam.nearVisibilityDistance) == 0.1
                    expect(defaultCam.farVisibilityDistance) == 1000.0
                    expect(defaultCam.fieldOfView) == Float(53.999996185302734375)
                }

                it("is created with near-visibility-distance, far-visibility-distance and field-of-view") {
                    // these are required and produce a corresponding projection matrix (formerly perspective)
                }

                it("can be set to look at a position and look from a position") {
                    // look-at (and optionally look-from)
                }

                it("can have a transform attached to it") {

                }

            }

            describe("StereoscopicCamera") {
                it("loads default values") {
                    expect(defaultStereoCam.nearVisibilityDistance) == 0.1
                    expect(defaultStereoCam.farVisibilityDistance) == 1000.0
                    expect(defaultStereoCam.fieldOfView) == Float(53.999996185302734375)

                    // TODO: default stereo values
                    expect(defaultStereoCam.interPupillaryDistance) == 63.0
                    expect(defaultStereoCam.leftVergence) == 0.0
                    expect(defaultStereoCam.rightVergence) == 0.0
                    expect(defaultStereoCam.overlap) == 0.0
                }
                
                it("is created by additionally specifying interPupillaryDistance, overlap & left/right vergence") {
                    
                }
                
                // it can attach a physical-lens
                // it can attach a physical-imaging-surface
            }
        }
        
        describe("Texture") {
            
            
        }
        
        describe("TextureFilter") {
            let wrapClamp = MDLMaterialTextureWrapMode.Clamp
            let wrapRepeat = MDLMaterialTextureWrapMode.Repeat
            let wrapMirror = MDLMaterialTextureWrapMode.Mirror
            let linear = MDLMaterialTextureFilterMode.Linear
            let nearest = MDLMaterialTextureFilterMode.Nearest
            let mipmapLinear = MDLMaterialMipMapFilterMode.Linear
            let mipmapNearest = MDLMaterialMipMapFilterMode.Nearest
            
            it("parses the correct defaults") {
                let defaultFilter = spectraParser.getTextureFilter("default")!

                expect(defaultFilter.rWrapMode) == wrapClamp
                expect(defaultFilter.tWrapMode) == wrapClamp
                expect(defaultFilter.sWrapMode) == wrapClamp
            }

            it("parses other texture filters") {
                let filterClamp = spectraParser.getTextureFilter("filter_clamp")!
                let filterRepeat = spectraParser.getTextureFilter("filter_repeat")!
                let filterMirror = spectraParser.getTextureFilter("filter_mirror")!
                let filterLinear = spectraParser.getTextureFilter("filter_linear")!
                let filterNearest = spectraParser.getTextureFilter("filter_nearest")!
                
                expect(filterClamp.rWrapMode) == wrapClamp
                expect(filterClamp.tWrapMode) == wrapClamp
                expect(filterClamp.sWrapMode) == wrapClamp

                expect(filterRepeat.rWrapMode) == wrapRepeat
                expect(filterRepeat.tWrapMode) == wrapRepeat
                expect(filterRepeat.sWrapMode) == wrapRepeat

                expect(filterMirror.rWrapMode) == wrapMirror
                expect(filterMirror.tWrapMode) == wrapMirror
                expect(filterMirror.sWrapMode) == wrapMirror

                expect(filterLinear.minFilter) == linear
                expect(filterLinear.magFilter) == linear
                expect(filterLinear.mipFilter) == mipmapLinear

                expect(filterNearest.minFilter) == nearest
                expect(filterNearest.magFilter) == nearest
                expect(filterNearest.mipFilter) == mipmapNearest
            }

            it("generates a MDLTextureFilter") {

            }
        }

        describe("TextureSampler") {
            // texture: MDLTexture
            // hardwareFilter: MDLTextureFilter
            // transform: MDLTransform (translate/scale/rotate textures relative to their surfaces)
            
            // TODO: MDLTextureSampler => MTLTextureSampler
            
            it("parses texture samplers") {
                
            }
            
            it("generates a MDLTextureSampler") {
                
            }
        }


    }
}
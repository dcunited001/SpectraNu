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
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "SpectraXMLSpec")
        let assetContainer = Container(parent: parser)

        SpectraXML.initParser(parser)
        let spectraXML = SpectraXML(parser: parser, data: xmlData)
        spectraXML.parse(assetContainer, options: [:])

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
                
                let attrPos2: MDLVertexAttribute = self.containerGet(assetContainer, key: "pos_float4")!
                expect(attrPos.bufferIndex) != attrPos2.bufferIndex
                expect(attrPos2.bufferIndex) == origAttrPosIndex
            }
        }
        
        describe("vertex-descriptor") {
            it("can parse vertex descriptor with references to vertex attributes") {

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
                // should it create a separate 'world-object' with it's own transform hierarchy?
            }
        }
        
        describe("mesh") {
            //TODO: doc mesh attributes
        }
        
        describe("mesh-generator") {
            //TODO: doc mesh-generator attributes
        }
        
        describe("object") {
            it("can create root objects that can be used to contain other objects") {
                // i think this is the best place for this?
                // - or object container?
            }
        }
        
        describe("MDLCamera") {
            let lens1: SpectraPhysicalLensParams = self.containerGet(assetContainer, key: "lens1")!
            let lens2: SpectraPhysicalLensParams = self.containerGet(assetContainer, key: "lens2")!
            let lens3: SpectraPhysicalLensParams = self.containerGet(assetContainer, key: "lens3")!
            
            describe("physical-lens") {
                it("can specify Physical Lens parameters") {
                    expect(lens1.barrelDistortion) == 0.1
                    expect(lens1.fisheyeDistortion) == 0.1
                    
                    // - barrelDistorion: Float
                    // - fisheyeDistorion: Float
                    // - opticalVignetting: Float
                    // - chromaticAberration: Float
                    // - focalLength: Float
                    // - fStop: Float
                    // - apertureBladeCount: Int
                    // - bokehKernelWithSize: vector_int2 -> MDLTexture
                    // - maximumCircleOfConfusion: Float
                    // - focusDistance: Float
                    // - shutterOpenInterval: NSTimeInterval
                }
            }
            
            describe("physical-imaging-surface") {
                it("can specify Physical Imaging Surface parameters ") {
                    // the renderer must support the math
                    // - sensorVerticalAperture: Float
                    // - sensorAspect: Float
                    // - sensorEnlargement: vector_float2
                    // - sensorShift: vector_float2
                    // - flash: vector_float3
                    // - exposure: vector_float3
                    // - exposureCompression: vector_float2
                }
            }
            
            describe("camera") {
                let defaultCam: MDLCamera = self.containerGet(assetContainer, key: "default")!
                let cam1: MDLCamera = self.containerGet(assetContainer, key: "cam1")!
                
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
            }
            
            describe("stereoscopic-camera") {
                it("is created by additionally specifying interPupillaryDistance, overlap & left/right vergence") {
                    
                }
                
                // it can attach a physical-lens
                // it can attach a physical-imaging-surface
            }
        }
        
        describe("asset") {
            it("can load a MDLAsset, but only from a file url") {
                
            }
            
            it("can load a MDLAsset with a URL & vertex descriptor") {
                
            }
            
            it("can load a MDLAsset with a URL, vertex descriptor & buffer allocator") {
                
            }
            
            it("can load a MDLAsset while preserving the topology") {
                
            }
        }
        
        describe("texture") {
            it("can init a texture with nil data to be written to later") {
                // TODO: figure out how to best splat pixel data into a NSData? array
                // - NSData generation can be deferred - `pixelData: nil` is allowed
                //   - in this case, can i write to the NSData? object from texelDataWithTopLeftOrigin() ???
                //   - if so, this is useful.  if not, it's not and i have no idea how to write to it.
            }
            
            it("can init a texture, specifying a spectra texture data generator for deferred execution") {
                
            }
            
            it("can create the various types of MDLTexture subclasses") {
                // MDLCheckerboardTexture
                // MDLColorSwatchTexture
                // MDLNoiseTexture
                // MDLNormalMapTexture
                // MDLSkyCubeTexture
                // MDLURLTexture
            }
            
            it("can load a texture from a bundle resource") {
                
            }
            
            it("can load a texture from a named bundle resource") {
                
            }
            
            it("can load a texture cube from a bundle resource") {
                
            }
            
            it("can load a texture cube from a named bundle resource") {
                
            }
            
            it("can load a texture from a url") {
                
            }
        }
        
        describe("texture-filter") {
            // describes wrapping texture to objects (clamping/etc)
            
            // Managing Texture Coordinate Wrap Modes (for values outside 0 to 1)
            // sWrapMode: wrap 1st texture coord
            // tWrapMode: wrap 2nd texture coord
            // rWrapMode: wrap 3rd texture coord
            
            // Managing Texture Filter Modes
            // minFilter: rendering textures at sizes smaller than that of the original image.
            // magFilter: rendering textures at sizes larger than that of the original image.
            // mipFilter: rendering textures with mip maps

            // enum: MDLMaterialTextureWrapMode
            // enum: MDLMaterialTextureFilterMode
            // enum: MDLMaterialMipMapFilterMode
            
            // TODO: MDLTextureFilter => MTLTextureFilter
        }
        
        describe("texture-sampler") {
            // texture: MDLTexture
            // hardwareFilter: MDLTextureFilter
            // transform: MDLTransform (translate/scale/rotate textures relative to their surfaces)
            
            // TODO: MDLTextureSampler => MTLTextureSampler
        }
        
        describe("light") {
            // TODO: finish filling out attributes
            // - MDLLightProbe
            // - MDLPhysicallyPlausibleLight
            // - MDLPhotometricLight
        }
        
        describe("material") {
            // initWithName:scatteringFunction:
            // - name: String
            // - scatteringFunction: MDLScatteringFunction (required)
            // - baseMaterial: MDLMaterial? (parent material which can material properties)
        }
        
        describe("material-property") {
            
            // - initWithName:semantic:URL:
            // - initWithName:semantic:textureSampler:
            // - initWithName:semantic:color:
            // - initWithName:semantic:float:
            // - initWithName:semantic:float2:
            // - initWithName:semantic:float3:
            // - initWithName:semantic:float4:
            // - initWithName:semantic:matrix4x4:
            
            // name: String
            // semantic: MDLMaterialSemantic
            // type: MDLMaterialPropertyType
            // stringValue: String?
            // URLValue: NSUrl?
            // textureSamplerValue: MDLTextureSampler
            // color: CGColor?
            // floatValue: Float
            // float2Value: vector_float2
            // float3Value: vector_float3
            // float4Value: vector_float4
            // matrix4x4: matrix_float4x4
            
            // copy with setProperties:MDLMaterialProperty
            
            // enum: MDLMaterialSemantic
            // enum: MDLMaterialPropertyType
        }
        
        describe("scattering-function") {
            // defines response to lighting for a MDLMaterial object
            // - i'll need to be knee deep in shaders before messing with this
            //   - and depthStencils with blitting, i think
            
            // name: String
            // baseColor: MDLMaterialProperty
            // emission: MDLMaterialProperty
            // specular: MDLMaterialProperty
            // materialIndexOfRefraction: MDLMaterialProperty
            // interfaceIndexOfRefraction: MDLMaterialProperty
            // normal: MDLMaterialProperty
            // ambientOcclusion: MDLMaterialProperty
            // ambientOcclusionScale: MDLMaterialProperty

            // also includes MDLPhysicallyPlausibleScatteringFunction:
            //
            // subsurface: MDLMaterialProperty
            // metallic: MDLMaterialProperty
            // specularAmount: MDLMaterialProperty
            // specularTint: MDLMaterialProperty
            // roughness: MDLMaterialProperty
            // anisotropic: MDLMaterialProperty
            // anisotropicRotation: MDLMaterialProperty
            // sheen: MDLMaterialProperty
            // sheenTint: MDLMaterialProperty
            // clearcoat: MDLMaterialProperty
        }
        
        describe("voxel-array") {
            // transformations to voxels from meshes that are already loaded
        }
    }
}

//
//  SpectraXMLSpec.swift
//  
//
//  Created by David Conner on 2/23/16.
//
//

@testable import Spectra
import Quick
import Nimble

import ModelIO
import Swinject
import Metal
import simd

class SpectraXMLSpec: QuickSpec {
    
//    func containerGet<T>(container: Container, key: String) -> T? {
//        return container.resolve(T.self, name: key)
//    }
    
    override func spec() {
//        let parser = Container()
//        
//        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
//        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
//        spectraEnumXSD.parseEnumTypes(parser)
//        
//        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
//        let xmlData: NSData = SpectraXML.readXML(testBundle, filename: "SpectraXMLSpec")
//        let assetContainer = Container(parent: parser)
//        ModelIOTextureGenerators.loadTextureGenerators(assetContainer)
//
//        SpectraXML.initParser(parser)
//        let spectraXML = SpectraXML(parser: parser, data: xmlData)
//        spectraXML.parse(assetContainer, options: [:])
//
//        // TODO: move this to a new file?
//        describe("SpectraXML: main parser") {
//            describe("parser can register new D/I handlers for XML tags") {
//                // this kinda requires auto-injection, which isn't available for swinject
//            }
//            
//            describe("parser can also register custom types to return") {
//                it("allows resolution of SpectraXMLNodeType with custom types") {
//                    
//                }
//            }
//        }
//        

//        // TODO: convert from VertexDescriptor with array-of-struct to struct-of-array indexing
//        // TODO: convert MDLVertexDescriptor <=> MTLVertexDescriptor
//        
//        describe("world-view") {
//            it("can parse world view nodes") {
//                // should it create a separate 'world-object' with it's own transform hierarchy?
//            }
//        }
//        
//        describe("transform") {
//            let xformTranslate: MDLTransform = self.containerGet(assetContainer, key: "xform_translate")!
//            let xformRotate: MDLTransform = self.containerGet(assetContainer, key: "xform_rotate")!
//            let xformScale: MDLTransform = self.containerGet(assetContainer, key: "xform_scale")!
//            let xformShear: MDLTransform = self.containerGet(assetContainer, key: "xform_shear")!
////            let xformCompose1: MDLTransform = self.containerGet(assetContainer, key: "xform_compose1")!
////            let xformCompose2: MDLTransform = self.containerGet(assetContainer, key: "xform_compose2")!
//            
//            it("parses translation/rotation/scale/shear") {
//                //TODO: rotation with degrees
//                expect(SpectraSimd.compareFloat3(xformTranslate.translation, with: float3(10.0, 20.0, 30.0))).to(beTrue())
//                expect(SpectraSimd.compareFloat3(xformRotate.rotation, with: float3(0.25, 0.50, 1.0))).to(beTrue())
//                expect(SpectraSimd.compareFloat3(xformScale.scale, with: float3(2.0, 2.0, 2.0))).to(beTrue())
//                expect(SpectraSimd.compareFloat3(xformShear.shear, with: float3(10.0, 10.0, 1.0))).to(beTrue())
//            }
//            
////            it("correctly composes multiple operations") {
////                // check that translate/rotate/scale/shear is calculated correctly when composed
////            }
//        }
//        
//        describe("object") {
//            let scene1: MDLObject = self.containerGet(assetContainer, key: "scene1")!
//            
//            it("can create basic objects") {
//                let objDefault: MDLObject = self.containerGet(assetContainer, key: "default")!
//                expect(objDefault.transform).to(beNil())
//                expect(objDefault.name) == "default"
//            }
//            
//            it("can create nested objects") {
//                let xform: MDLTransform = self.containerGet(assetContainer, key: "xform_translate")!
//                let cam: MDLCamera = self.containerGet(assetContainer, key: "default")!
//                let stereoCam: MDLStereoscopicCamera = self.containerGet(assetContainer, key: "default")!
//                
//                expect(scene1.children)
//            }
//            
//            it("can create root objects that can be used to contain other objects") {
//                // i think this is the best place for this?
//                // - or object container?
//            }
//        }
//        
//        describe("MDLCamera") {
//            let lens1: PhysicalLensNode = self.containerGet(assetContainer, key: "lens1")!
//            let lens2: PhysicalLensNode = self.containerGet(assetContainer, key: "lens2")!
//            let lens3: PhysicalLensNode = self.containerGet(assetContainer, key: "lens3")!
//            
//            let physImg1: PhysicalImagingSurfaceNode = self.containerGet(assetContainer, key: "phys_img1")!
//            let physImg2: PhysicalImagingSurfaceNode = self.containerGet(assetContainer, key: "phys_img2")!
//            
//            // camera with defaults
//            // camera with lens applied
//            // camera with physImg applied
//            // camera with lookAt applied
//            
//            let defaultCam: MDLCamera = self.containerGet(assetContainer, key: "default")!
//            let cam1: MDLCamera = self.containerGet(assetContainer, key: "cam1")!
//            let cam2: MDLCamera = self.containerGet(assetContainer, key: "cam2")!
//            let cam3: MDLCamera = self.containerGet(assetContainer, key: "cam3")!
//            let cam4: MDLCamera = self.containerGet(assetContainer, key: "cam4")!
//            
//            let defaultStereoCam: MDLStereoscopicCamera = self.containerGet(assetContainer, key: "default")!
//            let stereoCam1: MDLStereoscopicCamera = self.containerGet(assetContainer, key: "stereo_cam1")!
//            let stereoCam2: MDLStereoscopicCamera = self.containerGet(assetContainer, key: "stereo_cam2")!
//            
//            describe("physical-lens") {
//                it("can specify Physical Lens parameters") {
//                    expect(lens1.barrelDistortion) == 0.1
//                    expect(lens1.fisheyeDistortion) == 0.5
//                    
//                    expect(lens2.focalLength) == 77.0
//                    expect(lens2.fStop) == 7.0
//                    expect(lens2.maximumCircleOfConfusion) == 0.10
//                    
//                    expect(lens3.apertureBladeCount) == 7
//                }
//            }
//            
//            describe("physical-imaging-surface") {
//                it("can specify Physical Imaging Surface parameters") {
//                    expect(physImg1.sensorVerticalAperture) == 24
//                    expect(physImg1.sensorAspect) == 2.0
//                    
//                    let expectedFlash = float3([0.1, 0.1, 0.1])
//                    let expectedExposure = float3([1.5, 1.5, 1.5])
//                    expect(SpectraSimd.compareFloat3(physImg2.flash!, with: float3([0.1, 0.1, 0.1]))).to(beTrue())
//                    expect(SpectraSimd.compareFloat3(physImg2.exposure!, with: float3([1.5, 1.5, 1.5]))).to(beTrue())
//                }
//            }
//            
//            describe("camera") {
//                it("manages the inherited MDLObject properties") {
//                    // transform
//                    // parent
//                }
//                
//                it("loads default values") {
//                    expect(defaultCam.nearVisibilityDistance) == 0.1
//                    expect(defaultCam.farVisibilityDistance) == 1000.0
//                    expect(defaultCam.fieldOfView) == Float(53.999996185302734375)
//                }
//                
//                it("is created with near-visibility-distance, far-visibility-distance and field-of-view") {
//                    // these are required and produce a corresponding projection matrix (formerly perspective)
//                }
//                
//                it("can be set to look at a position and look from a position") {
//                    // look-at (and optionally look-from)
//                }
//                
//                it("can have a transform attached to it") {
//                    
//                }
//                
//            }
//            
//            describe("stereoscopic-camera") {
//                it("loads default values") {
//                    expect(defaultStereoCam.nearVisibilityDistance) == 0.1
//                    expect(defaultStereoCam.farVisibilityDistance) == 1000.0
//                    expect(defaultStereoCam.fieldOfView) == Float(53.999996185302734375)
//                    
//                    // TODO: default stereo values
//                    expect(defaultStereoCam.interPupillaryDistance) == 63.0
//                    expect(defaultStereoCam.leftVergence) == 0.0
//                    expect(defaultStereoCam.rightVergence) == 0.0
//                    expect(defaultStereoCam.overlap) == 0.0
//                }
//                
//                it("is created by additionally specifying interPupillaryDistance, overlap & left/right vergence") {
//                    
//                }
//                
//                // it can attach a physical-lens
//                // it can attach a physical-imaging-surface
//            }
//        }
//        
//        describe("asset") {
////            let pencils = assetContainer.resolve(MDLAsset.self, name: "pencil_model")!
//            
//            it("can parse asset nodes") {
//
//            }
//            
//            it("can generate asset nodes") {
//                // TODO: how to generate environment-independent path?
//            }
//            
//            it ("can generate asset nodes with a vertex descriptor and/or buffer allocator") {
//                
//            }
//        }
//        
//        describe("texture") {
//            it("can init a texture with nil data to be written to later") {
//                // TODO: figure out how to best splat pixel data into a NSData? array
//                // - NSData generation can be deferred - `pixelData: nil` is allowed
//                //   - in this case, can i write to the NSData? object from texelDataWithTopLeftOrigin() ???
//                //   - if so, this is useful.  if not, it's not and i have no idea how to write to it.
//            }
//            
//            it("can init a texture, specifying a spectra texture data generator for deferred execution") {
//                
//            }
//            
//            it("can create the various types of MDLTexture subclasses") {
//                // MDLCheckerboardTexture
//                // MDLColorSwatchTexture
//                // MDLNoiseTexture
//                // MDLNormalMapTexture
//                // MDLSkyCubeTexture
//                // MDLURLTexture
//            }
//            
//            it("can load a texture from a bundle resource") {
//                
//            }
//            
//            it("can load a texture from a named bundle resource") {
//                
//            }
//            
//            it("can load a texture cube from a bundle resource") {
//                
//            }
//            
//            it("can load a texture cube from a named bundle resource") {
//                
//            }
//            
//            it("can load a texture from a url") {
//                
//            }
//        }
//        
//        describe("texture-filter") {
//            it("parses the correct defaults") {
//                let defaultFilter: MDLTextureFilter = self.containerGet(assetContainer, key: "default")!
//                
//                expect(defaultFilter.rWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                expect(defaultFilter.tWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                expect(defaultFilter.sWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                
//            }
//            
//            it("parses other texture filters") {
//                let filterClamp: MDLTextureFilter = self.containerGet(assetContainer, key: "filter_clamp")!
//                let filterRepeat: MDLTextureFilter = self.containerGet(assetContainer, key: "filter_repeat")!
//                let filterMirror: MDLTextureFilter = self.containerGet(assetContainer, key: "filter_mirror")!
//                let filterLinear: MDLTextureFilter = self.containerGet(assetContainer, key: "filter_linear")!
//                let filterNearest: MDLTextureFilter = self.containerGet(assetContainer, key: "filter_nearest")!
//                
//                expect(filterClamp.rWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                expect(filterClamp.tWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                expect(filterClamp.sWrapMode) == MDLMaterialTextureWrapMode.Clamp
//                
//                expect(filterRepeat.rWrapMode) == MDLMaterialTextureWrapMode.Repeat
//                expect(filterRepeat.tWrapMode) == MDLMaterialTextureWrapMode.Repeat
//                expect(filterRepeat.sWrapMode) == MDLMaterialTextureWrapMode.Repeat
//                
//                expect(filterMirror.rWrapMode) == MDLMaterialTextureWrapMode.Mirror
//                expect(filterMirror.tWrapMode) == MDLMaterialTextureWrapMode.Mirror
//                expect(filterMirror.sWrapMode) == MDLMaterialTextureWrapMode.Mirror
//                
//                expect(filterLinear.minFilter) == MDLMaterialTextureFilterMode.Linear
//                expect(filterLinear.magFilter) == MDLMaterialTextureFilterMode.Linear
//                expect(filterLinear.mipFilter) == MDLMaterialMipMapFilterMode.Linear
//                
//                expect(filterNearest.minFilter) == MDLMaterialTextureFilterMode.Nearest
//                expect(filterNearest.magFilter) == MDLMaterialTextureFilterMode.Nearest
//                expect(filterNearest.mipFilter) == MDLMaterialMipMapFilterMode.Nearest
//            }
//            
//            it("generates a MDLTextureFilter") {
//                
//            }
//        }
//        
//        describe("texture-sampler") {
//            // texture: MDLTexture
//            // hardwareFilter: MDLTextureFilter
//            // transform: MDLTransform (translate/scale/rotate textures relative to their surfaces)
//            
//            // TODO: MDLTextureSampler => MTLTextureSampler
//            
//            it("parses texture samplers") {
//                
//            }
//            
//            it("generates a MDLTextureSampler") {
//                
//            }
//        }
//        
//        describe("light") {
//            // TODO: finish filling out attributes
//            // - MDLLightProbe
//            // - MDLPhysicallyPlausibleLight
//            // - MDLPhotometricLight
//        }
//        
//        describe("material") {
//            // initWithName:scatteringFunction:
//            // - name: String
//            // - scatteringFunction: MDLScatteringFunction (required)
//            // - baseMaterial: MDLMaterial? (parent material which can material properties)
//        }
//        
//        describe("material-property") {
//            
//            // - initWithName:semantic:URL:
//            // - initWithName:semantic:textureSampler:
//            // - initWithName:semantic:color:
//            // - initWithName:semantic:float:
//            // - initWithName:semantic:float2:
//            // - initWithName:semantic:float3:
//            // - initWithName:semantic:float4:
//            // - initWithName:semantic:matrix4x4:
//            
//            // name: String
//            // semantic: MDLMaterialSemantic
//            // type: MDLMaterialPropertyType
//            // stringValue: String?
//            // URLValue: NSUrl?
//            // textureSamplerValue: MDLTextureSampler
//            // color: CGColor?
//            // floatValue: Float
//            // float2Value: vector_float2
//            // float3Value: vector_float3
//            // float4Value: vector_float4
//            // matrix4x4: matrix_float4x4
//            
//            // copy with setProperties:MDLMaterialProperty
//            
//            // enum: MDLMaterialSemantic
//            // enum: MDLMaterialPropertyType
//        }
//        
//        describe("scattering-function") {
//            // defines response to lighting for a MDLMaterial object
//            // - i'll need to be knee deep in shaders before messing with this
//            //   - and depthStencils with blitting, i think
//            
//            // name: String
//            // baseColor: MDLMaterialProperty
//            // emission: MDLMaterialProperty
//            // specular: MDLMaterialProperty
//            // materialIndexOfRefraction: MDLMaterialProperty
//            // interfaceIndexOfRefraction: MDLMaterialProperty
//            // normal: MDLMaterialProperty
//            // ambientOcclusion: MDLMaterialProperty
//            // ambientOcclusionScale: MDLMaterialProperty
//
//            // also includes MDLPhysicallyPlausibleScatteringFunction:
//            //
//            // subsurface: MDLMaterialProperty
//            // metallic: MDLMaterialProperty
//            // specularAmount: MDLMaterialProperty
//            // specularTint: MDLMaterialProperty
//            // roughness: MDLMaterialProperty
//            // anisotropic: MDLMaterialProperty
//            // anisotropicRotation: MDLMaterialProperty
//            // sheen: MDLMaterialProperty
//            // sheenTint: MDLMaterialProperty
//            // clearcoat: MDLMaterialProperty
//        }
//        
//        describe("voxel-array") {
//            // transformations to voxels from meshes that are already loaded
//        }
    }
}

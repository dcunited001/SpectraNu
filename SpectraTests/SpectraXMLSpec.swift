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

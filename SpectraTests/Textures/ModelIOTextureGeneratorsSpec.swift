//
//  ModelIOTextureGenerators.swift
//  
//
//  Created by David Conner on 3/8/16.
//
//

@testable import Spectra
import Foundation
import Quick
import Nimble
import ModelIO
import Swinject

class ModelIOTextureGeneratorsSharedExamples: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("A Model I/O Texture Generator") {
            it("foos") {
                
            }
        }
    }
}

class ModelIOTextureGeneratorsSpec: QuickSpec {

    override func spec() {
        describe("must foo") {
            it("to bar") {
                
            }
        }
        
//        let parser = Container()
//        
//        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
//        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
//        spectraEnumXSD.parseEnumTypes(parser)
//        
//        let testBundle = NSBundle(forClass: ModelIOTextureGeneratorsSpec.self)
//        let xmlData: NSData = SpectraXML.readXML(testBundle, filename: "ModelIOTextureGeneratorsSpec")
//        let assetContainer = Container(parent: parser)
//        
//        ModelIOTextureGenerators.loadTextureGenerators(assetContainer)
//        
//        SpectraXML.initParser(parser)
//        let spectraXML = SpectraXML(parser: parser, data: xmlData)
//        spectraXML.parse(assetContainer, options: [:])
//        
//        describe("resource_texture") {
//            let texGen = assetContainer.resolve(TextureGenerator.self, name: "resource_texture_gen") as! ResourceTextureGen
//            
//            it("can override generator defaults") {
//                expect(texGen.resource) == "defaultTexture.jpg"
//            }
//            
//            it("creates meshes") {
//                let tex = assetContainer.resolve(MDLTexture.self, name: "resource_tex")
//                print(tex)
//            }
//        }
//        
//        // TODO:  describe("resource_cube_texture") { }
//        
//        describe("url_texture") {
//            let texGen = assetContainer.resolve(TextureGenerator.self, name: "url_texture_gen2") as! URLTextureGen
//            let texURL = NSURL(fileURLWithPath: "file:///itsafile.jpg")
//            
//            it("can override generator defaults") {
//                // TODO: manually set texture URL on generator using $(PROJECT_PATH)
//                expect(texGen.url?.absoluteString) == texURL.absoluteString
//            }
//        }
//        
//        describe("vector_noise_texture") {
//            let texGen = assetContainer.resolve(TextureGenerator.self, name: "vector_noise_gen") as! NoiseTextureGen
//            
//            it("can override generator defaults") {
//                expect(texGen.type) == NoiseTextureGenType.Vector
//                expect(texGen.dimensions[0]) == 10
//                expect(texGen.dimensions[1]) == 10
//            }
//            
//            it("creates meshes") {
//                let tex = assetContainer.resolve(MDLTexture.self, name: "vector_noise_tex")!
//                expect(tex.dimensions[0]) == 10
//                expect(tex.dimensions[1]) == 10
//            }
//        }
//        
//        describe("scalar_noise_texture") {
//            let texGen = assetContainer.resolve(TextureGenerator.self, name: "scalar_noise_gen") as! NoiseTextureGen
//            
//            it("can override generator defaults") {
//                expect(texGen.type) == NoiseTextureGenType.Scalar
//                expect(texGen.dimensions[0]) == 10
//                expect(texGen.dimensions[1]) == 10
//            }
//            
//            it("creates meshes") {
//                let tex = assetContainer.resolve(MDLTexture.self, name: "scalar_noise_tex")!
//                expect(tex.dimensions[0]) == 10
//                expect(tex.dimensions[1]) == 10
//            }
//        }
//        
//        describe("checkerboard_texture_gen") {
//            let texGen = assetContainer.resolve(TextureGenerator.self, name: "checkerboard_texture_gen2") as! CheckerboardTextureGen
//            
//            it("can override generator defaults") {
//                expect(texGen.divisions) == 19
//                expect(texGen.dimensions[0]) == 19
//                expect(texGen.dimensions[1]) == 19
//            }
//        }
//        
//        // TODO: describe("data_texture") { }
//        // TODO: describe("color_swatch_texture") { }
//        // TODO: describe("normal_map_texture") { }
//        // TODO: describe("sky_cube_texture") { }
        
    }
}
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

// TODO: test overriding args in generate()

class ModelIOTextureGeneratorsSpec: QuickSpec {
    
    override func spec() {
        let parser = Container()
        
        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
        spectraEnumXSD.parseEnumTypes(parser)
        
        let testBundle = NSBundle(forClass: ModelIOTextureGeneratorsSpec.self)
        let xmlData: NSData = SpectraXML.readXML(testBundle, filename: "ModelIOTextureGenerators")
        let assetContainer = Container(parent: parser)
        
        ModelIOTextureGenerators.loadTextureGenerators(assetContainer)
        
        SpectraXML.initParser(parser)
        let spectraXML = SpectraXML(parser: parser, data: xmlData)
        spectraXML.parse(assetContainer, options: [:])
        
        describe("resource_texture") {
            let texGen = assetContainer.resolve(TextureGenerator.self, name: "resource_tex_gen")
            
            it("can override generator defaults") {
                expect(texGen.name) == "defaultTexture.jpg"
            }
            
            it("creates meshes") {
                let tex = assetContainer.resolve(MDLTexture.self, name: "resource_tex")
                print(tex)
            }
        }
        
        // TODO:  describe("resource_cube_texture") { }
        
        describe("url_texture") {
            let texGen = assetContainer.resolve(TextureGenerator.self, name: "url_tex_gen2")
            
            it("can override generator defaults") {
                // TODO: manually set texture URL on generator using $(PROJECT_PATH)
                expect(texGen.url) == "file:///itsafile.jpg"
            }
        }
        
        describe("vector_noise_texture") {
            let texGen = assetContainer.resolve(TextureGenerator.self, name: "vector_noise_gen")
            
            it("can override generator defaults") {
                // TODO: more validations
                expect(texGen.type) == NoiseTextureGenType.Vector
                expect(texGen.dimensions[0]) == 10
                expect(texGen.dimensions[1]) == 10
            }
            
            it("creates meshes") {
                let tex = assetContainer.resolve(MDLTexture.self, name: "vector_noise_tex")
                expect(tex.dimensions[0]) == 10
                expect(tex.dimensions[1]) == 10
            }
        }
        
        describe("scalar_noise_texture") {
            let texGen = assetContainer.resolve(TextureGenerator.self, name: "scalar_noise_gen")
            
            it("can override generator defaults") {
                // TODO: more validations
                expect(texGen.type) == NoiseTextureGenType.Scalar
                expect(texGen.dimensions[0]) == 10
                expect(texGen.dimensions[1]) == 10
            }
            
            it("creates meshes") {
                let tex = assetContainer.resolve(MDLTexture.self, name: "scalar_noise_gen")
                expect(tex.dimensions[0]) == 10
                expect(tex.dimensions[1]) == 10
            }
        }
        
        describe("checkerboard_texture_gen") {
            let texGen = assetContainer.resolve(TextureGenerator.self, name: "scalar_noise_gen")
            
            it("can override generator defaults") {
                expect(texGen.divisions) == 19
                expect(texGen.dimensions[0]) == 19
                expect(texGen.dimensions[1]) == 19
            }
        }
        
        // TODO: describe("data_texture") { }
        // TODO: describe("color_swatch_texture") { }
        // TODO: describe("normal_map_texture") { }
        // TODO: describe("sky_cube_texture") { }
        
    }
}
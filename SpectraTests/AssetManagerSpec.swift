//
//  AssetManagerSpec.swift
//  
//
//  Created by David Conner on 2/22/16.
//
//

@testable import Spectra
import Foundation
import Quick
import Nimble
import ModelIO

class AssetManagerSpec: QuickSpec {
    
    override func spec() {
        
        let testBundle = NSBundle(forClass: AssetManagerSpec.self)
//        let xmlData: NSData =
        
        var assetMan = AssetManager()
        
        describe("SpectraEnums") {
            it("loads the enums for ModelIO and/or Metal") {
                let f4 = assetMan.getEnum("mdlVertexFormat", id: "Float4")
                expect(f4) == MDLVertexFormat.Float4.rawValue
                
                let materialSemantic = assetMan.getEnum("mdlMaterialSemantic", id: "SpecularExponent")
                expect(materialSemantic) == MDLMaterialSemantic.SpecularExponent.rawValue
                
                let materialPropertyType = assetMan.getEnum("mdlMaterialPropertyType", id: "Texture")
                expect(materialPropertyType) == MDLMaterialPropertyType.Texture.rawValue
                
                let textureWrapMode = assetMan.getEnum("mdlMaterialTextureWrapMode", id: "Clamp")
                expect(textureWrapMode) == MDLMaterialTextureWrapMode.Clamp.rawValue
                
                let textureFilterMode = assetMan.getEnum("mdlMaterialTextureFilterMode", id: "Linear")
                expect(textureFilterMode) == MDLMaterialTextureFilterMode.Linear.rawValue
                
                let mipMapFilterMode = assetMan.getEnum("mdlMaterialMipMapFilterMode", id: "Linear")
                expect(mipMapFilterMode) == MDLMaterialMipMapFilterMode.Linear.rawValue
            }
        }
        
        describe("SpectraVertexAttrType") {
            // had some issues just making an enum with the values,
            // - bc enums must be created with string literals
            // so i'm keeping this in for now as a check, 
            // - in case the values don't match, per-platform or somethin
            
            it("pulls the right values") {
                expect(SpectraVertexAttrType.Anisotropy.rawValue) == MDLVertexAttributeAnisotropy
                expect(SpectraVertexAttrType.Binormal.rawValue) == MDLVertexAttributeBinormal
                expect(SpectraVertexAttrType.Bitangent.rawValue) == MDLVertexAttributeBitangent
                expect(SpectraVertexAttrType.Color.rawValue) == MDLVertexAttributeColor
                expect(SpectraVertexAttrType.EdgeCrease.rawValue) == MDLVertexAttributeEdgeCrease
                expect(SpectraVertexAttrType.JointIndices.rawValue) == MDLVertexAttributeJointIndices
                expect(SpectraVertexAttrType.JointWeights.rawValue) == MDLVertexAttributeJointWeights
                expect(SpectraVertexAttrType.Normal.rawValue) == MDLVertexAttributeNormal
                expect(SpectraVertexAttrType.OcclusionValue.rawValue) == MDLVertexAttributeOcclusionValue
                expect(SpectraVertexAttrType.Position.rawValue) == MDLVertexAttributePosition
                expect(SpectraVertexAttrType.ShadingBasisU.rawValue) == MDLVertexAttributeShadingBasisU
                expect(SpectraVertexAttrType.ShadingBasisV.rawValue) == MDLVertexAttributeShadingBasisV
                expect(SpectraVertexAttrType.SubdivisionStencil.rawValue) == MDLVertexAttributeSubdivisionStencil
                expect(SpectraVertexAttrType.Tangent.rawValue) == MDLVertexAttributeTangent
                expect(SpectraVertexAttrType.TextureCoordinate.rawValue) == MDLVertexAttributeTextureCoordinate
            }
        }
    
    }
    
}

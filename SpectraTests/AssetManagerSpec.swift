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
                let f4 = assetMan.getEnum("mdlVertexFormat", key: "Float4")
                expect(f4) == MDLVertexFormat.Float4.rawValue
            }
        }
    
    }
    
}

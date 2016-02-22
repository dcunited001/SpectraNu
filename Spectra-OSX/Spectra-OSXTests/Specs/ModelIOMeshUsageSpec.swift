//
//  ModelIOMeshUsageSpec.swift
//  SpectraOSX
//
//  Created by David Conner on 2/21/16.
//  Copyright © 2016 Spectra. All rights reserved.
//

@testable import Spectra
import Foundation
import Quick
import Nimble
import ModelIO

class ModelIOMeshUsageSpec: QuickSpec {
    
    // NOTE: this spec is really for my benefit, so I can play around with some MDLMeshBuffer examples.  i need to determine the following:
    // - how to create/structure MDLVertexDescriptors & how best to read the definitions for these in via XML
    // - how to combinate MDLVertexAttribute's for mesh buffers.  how to adapt for differing lengths for the same type of attribute
    // - how to convert from 'structure of arrays' format to 'array of structures' format, when altering mesh or adding an attribute or something.
    // - how to convert from MDLVertexDescriptor to MTLVertexDescriptor.  can i automate this?  all of it (even binding that descriptor's definition to the shaders? swift seemed to not be capable of this)
    // - how to structure dependency injection for geometry

    // important observation: the submeshes (formerly dataMaps) should never change because a vertexAttribute changed
    // - that is, in the simplest use case for submeshes
    
    enum Foo: Int {
        case Bar
        case Baz
    }
    
    override func spec() {
        
        describe("MDLVertexDescriptor") {

            let attrPosition = MDLVertexAttribute(name: MDLVertexAttributePosition, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 0)
            let attrColor = MDLVertexAttribute(name: MDLVertexAttributeColor, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 1)
            let attrTexture = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: MDLVertexFormat.Float2, offset: 0, bufferIndex: 2)
            let attrAnisotropy = MDLVertexAttribute(name: MDLVertexAttributeAnisotropy, format: MDLVertexFormat.Float4, offset: 0, bufferIndex: 3)
            
            it("has a MDLVertexFormat enum type that can be reflected") {
                let mirror = Mirror(reflecting: MDLVertexFormat.Float4)
                print(String(reflecting: MDLVertexFormat.Float4))
                print(MDLVertexFormat.Float4.rawValue)
                print(MDLVertexFormat.Float3.rawValue)
                print(MDLVertexFormat.Float.rawValue)
                
                print(MDLVertexFormat.Int4.rawValue)
                print(MDLVertexFormat.Int4.hashValue)
                print(MDLVertexFormat(rawValue: 53)!.rawValue)
                print(MDLVertexFormat.Int2.rawValue)
                print(MDLVertexFormat.Int2.hashValue)
                print(MDLVertexFormat(rawValue: 51)!.rawValue)
                print(MDLVertexFormat.Int.rawValue)
                print(MDLVertexFormat.Int.hashValue)
                print(MDLVertexFormat(rawValue: 50)!.rawValue)
                print(MTLVertexFormat.Float4.rawValue)
                print(MTLVertexFormat.Float3.rawValue)
                print(MTLVertexFormat.Float2.rawValue)
                print(MTLVertexFormat.Float.rawValue)
                print(MTLVertexFormat(rawValue: 28)!.rawValue)
                print(MTLVertexFormat(rawValue: 29)!.rawValue)
                print(MTLVertexFormat(rawValue: 30)!.rawValue)
                print(MTLVertexFormat.Invalid.rawValue)
                print(MTLVertexFormat(rawValue: 0)!.rawValue)
                print(MDLVertexFormat.Invalid.rawValue)
                print(MDLVertexFormat(rawValue: 0)!.rawValue)
                mirror
                print(Foo.Bar)
                print(Foo.Baz)
            }

        }
        
        describe("MDLMeshBufferData") {
            it("parses enumGroups from XSD") {

            }
        }
        
        describe("MDLMesh generaters (cube/cylider/etc)") {
            // this might be the best way to inspect structure for MDLMeshBuffer (though i think i got it now)
            // - the unknown was the expected byte structure of items in the buffer, but this is defined by VertexDescriptor
        }
        
    }
}

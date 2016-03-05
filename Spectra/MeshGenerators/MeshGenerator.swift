//
//  MeshGenerator.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import ModelIO
import simd
import Swinject

public protocol MeshGenerator {
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLMesh
    init(container: Container, args: [String: GeneratorArg])
}

//public typealias MeshGeneratorMonad = ((Container, ) -> )

// NOTE: trying to decouple SpectraGeo from the rest of Spectra
// - or at least parts of it

public class SpectraGeo {
    
    public static func defaultVertexDescriptor() -> MDLVertexDescriptor {
        // this vertex desc can be replaced,
        // - but this descriptor describes the data layout
        
        let attrPos = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .Float4, offset: 0, bufferIndex: 0)
        let attrColor = MDLVertexAttribute(name: MDLVertexAttributeColor, format: .Int4, offset: 0, bufferIndex: 1)
        let attrTex = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .Float4, offset: 0, bufferIndex: 2)
        let attrNorm = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .Float4, offset: 0, bufferIndex: 3)
        
        let desc = MDLVertexDescriptor()
        desc.addOrReplaceAttribute(attrPos)
        desc.addOrReplaceAttribute(attrColor)
        desc.addOrReplaceAttribute(attrTex)
        desc.addOrReplaceAttribute(attrNorm)
        
        return desc
    }
    
    // TODO: move this elsewhere

//    public static func getClassForVertexFormat(vertexFormat: MDLVertexFormat) -> Any {
//        switch vertexFormat {
        // TODO: i had hoped to use return the class here, then reference this in the generateData() method
        // - to infer type on a variable that would receive the value from the generic generateAttribute() method
        // - but i can't really do much with structs =/
//        }
//    }
    
}


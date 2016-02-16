//
//  DescriptorManager.swift
//  Pods
//
//  Created by David Conner on 10/19/15.
//
//

import Foundation
import Metal
import Fuzi
import Swinject

public class SpectraDescriptorManager {
    public var library: MTLLibrary // TODO: support multiple libraries?
    
    public var xsd: S3DXSD
    public var container: Container = Container()
    
    //TODO: consolidate vertex/fragment/compute functions as getMtlFunction()?
    public func getVertexFunction(key: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: key)!
    }
    
    public func getFragmentFunction(key: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: key)!
    }
    
    public func getComputeFunction(key: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: key)!
    }
    
    public func getVertexDescriptor(key: String) -> MTLVertexDescriptor {
        return container.resolve(MTLVertexDescriptor.self, name: key)!
    }
    
    public func getTextureDescriptor(key: String) -> MTLTextureDescriptor {
        return container.resolve(MTLTextureDescriptor.self, name: key)!
    }
    
    public func getSamplerDescriptor(key: String) -> MTLSamplerDescriptor {
        return container.resolve(MTLSamplerDescriptor.self, name: key)!
    }
    
    public func getStencilDescriptor(key: String) -> MTLStencilDescriptor {
        return container.resolve(MTLStencilDescriptor.self, name: key)!
    }
    
    public func getDepthStencilDescriptor(key: String) -> MTLDepthStencilDescriptor {
        return container.resolve(MTLDepthStencilDescriptor.self, name: key)!
    }
    
    public func getColorAttachmentDescriptor(key: String) -> MTLRenderPipelineColorAttachmentDescriptor {
        return container.resolve(MTLRenderPipelineColorAttachmentDescriptor.self, name: key)!
    }
    
    public func getRenderPipelineDescriptor(key: String) -> MTLRenderPipelineDescriptor {
        return container.resolve(MTLRenderPipelineDescriptor.self, name: key)!
    }
    
    public func getRenderPassColorAttachmentDescriptor(key: String) -> MTLRenderPassColorAttachmentDescriptor {
        return container.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: key)!
    }
    
    public func getRenderPassDepthAttachmentDescriptor(key: String) -> MTLRenderPassDepthAttachmentDescriptor {
        return container.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: key)!
    }
    
    public func getRenderPassStencilAttachmentDescriptor(key: String) -> MTLRenderPassStencilAttachmentDescriptor {
        return container.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: key)!
    }
    
    public func getRenderPassDescriptor(key: String) -> MTLRenderPassDescriptor {
        return container.resolve(MTLRenderPassDescriptor.self, name: key)!
    }
    
    public func getComputePipelineDescriptor(key: String) -> MTLComputePipelineDescriptor {
        return container.resolve(MTLComputePipelineDescriptor.self, name: key)!
    }
    
    public init(library: MTLLibrary) {
        self.library = library
        
        // just parsing enum types from XSD for now
        let xmlData = S3DXSD.readXSD("Spectra3D")
        xsd = S3DXSD(data: xmlData)
        xsd.parseEnumTypes(container)
    }
    
    public func getMtlEnum(name: String, key: String) -> UInt {
        return container.resolve(S3DMtlEnum.self, name: name)!.getValue(key)
    }
    
    public func parseS3DXML(s3d: S3DXML) {
        for child in s3d.xml!.root!.children {
            let tag = child.tag!
            let key = child.attributes["key"]
            
            switch tag {
            case "vertex-function", "fragment-function", "compute-function":
                let mtlFunction = S3DXMLMTLFunctionNode(library: library).parse(container, elem: child)
                container.register(MTLFunction.self, name: key!) { r in
                    return mtlFunction
                    }.inObjectScope(.Container)
                
                //TODO: remove if a single type is sufficient
                //            case "fragment-function":
                //                container.register(MTLFunction.self, name: key!) { _ in
                //                    return S3DXMLMTLFunctionNode().parse(container, elem: child)
                //                }.inObjectScope(.Container)
                //            case "compute-function":
                //                container.register(MTLFunction.self, name: key!) { _ in
                //                    return S3DXMLMTLFunctionNode().parse(container, elem: child)
                //                    }.inObjectScope(.Container)
            case "vertex-descriptor":
                container.register(MTLVertexDescriptor.self, name: key!) { r in
                    return S3DXMLMTLVertexDescriptorNode().parse(r as! Container, elem: child)
                    }.inObjectScope(.Container)
            case "texture-descriptor":
                container.register(MTLTextureDescriptor.self, name: key!) { r in
                    return S3DXMLMTLTextureDescriptorNode().parse(r as! Container, elem: child)
                    }.inObjectScope(.Container)
            case "sampler-descriptor":
                container.register(MTLSamplerDescriptor.self, name: key!) { r in
                    return S3DXMLMTLSamplerDescriptorNode().parse(r as! Container, elem: child)
                    }.inObjectScope(.Container)
                //            case "stencil-descriptor":
                //                container.register(MTLStencilDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "depth-stencil-descriptor":
                //                container.register(MTLDepthStencilDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "render-pipeline-color-attachment-descriptor":
                //                container.register(MTLRenderPipelineColorAttachmentDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "compute-pipeline-descriptor":
                //                container.register(MTLComputePipelineDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "render-pipeline-descriptor":
                //                container.register(MTLRenderPipelineDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "render-pass-color-attachment-descriptor":
                //                container.register(MTLRenderPassColorAttachmentDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "render-pass-depth-attachment-descriptor":
                //                container.register(MTLRenderPassDepthAttachmentDescriptor.self, name: key!) { r in
                //
                //                }.inObjectScope(.Container)
                //            case "render-pass-stencil-attachment-descriptor":
                //                container.register(MTLRenderPassStencilAttachmentDescriptor.self, name: key!) { r in
                //                    
                //                }.inObjectScope(.Container)
                //            case "render-pass-descriptor":
                //                container.register(MTLRenderPassDescriptor.self, name: key!) { r in
                //                    
                //                }.inObjectScope(.Container)
            default:
                break
            }
        }
    }
}
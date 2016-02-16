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
    
    public var vertexFunctions: [String: MTLFunction] = [:]
    public var fragmentFunctions: [String: MTLFunction] = [:]
    public var computeFunctions: [String: MTLFunction] = [:]
    
    public var vertexDescriptors: [String: MTLVertexDescriptor] = [:]
    public var textureDescriptors: [String: MTLTextureDescriptor] = [:]
    public var samplerDescriptors: [String: MTLSamplerDescriptor] = [:]
    public var stencilDescriptors: [String: MTLStencilDescriptor] = [:]
    public var depthStencilDescriptors: [String: MTLDepthStencilDescriptor] = [:]
    public var colorAttachmentDescriptors: [String: MTLRenderPipelineColorAttachmentDescriptor] = [:]
    public var renderPipelineDescriptors: [String: MTLRenderPipelineDescriptor] = [:]
    public var renderPassColorAttachmentDescriptors: [String: MTLRenderPassColorAttachmentDescriptor] = [:]
    public var renderPassDepthAttachmentDescriptors: [String: MTLRenderPassDepthAttachmentDescriptor] = [:]
    public var renderPassStencilAttachmentDescriptors: [String: MTLRenderPassStencilAttachmentDescriptor] = [:]
    public var renderPassDescriptors: [String: MTLRenderPassDescriptor] = [:]
    public var computePipelineDescriptors: [String: MTLComputePipelineDescriptor] = [:]
    
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
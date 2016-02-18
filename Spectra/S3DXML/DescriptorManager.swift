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
    
    public func getClearColor(key: String) -> MTLClearColor {
        return container.resolve(MTLClearColor.self, name: key)!
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
        self.container.register(MTLLibrary.self, name: "default") { _ in return library }.inObjectScope(.Container)
        
        // just parsing enum types from XSD for now
        let xmlData = S3DXSD.readXSD("Spectra3D")
        xsd = S3DXSD(data: xmlData)
        xsd.parseEnumTypes(container)
    }
    
    public func getMtlEnum(name: String, key: String) -> UInt {
        return container.resolve(S3DMtlEnum.self, name: name)!.getValue(key)
    }
    
    public func assembleHigherOrderFactories() {
        //TODO: register factories to produce higher order objects,
        // at least these, with dependencies that are built with container.resolve() calls
        // - MTLDepthStencilDescriptor
        // - MTLColorAttachmentDescriptor
        // - S3DXMLMTLRenderPipelineDescriptor

        assembleRenderPassFactories(container)
    }
    
    public func parseS3DXML(s3d: S3DXML) {
        for child in s3d.xml!.root!.children {
            let tag = child.tag!
            let key = child.attributes["key"]
            
            switch tag {
            case "vertex-function", "fragment-function", "compute-function":
                let mtlFunction = S3DXMLMTLFunctionNode(library: library).parse(container, elem: child)
                container.register(MTLFunction.self, name: key!) { _ in
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
                let vertexDesc = S3DXMLMTLVertexDescriptorNode().parse(container, elem: child)
                container.register(MTLVertexDescriptor.self, name: key!) { _ in
                    return vertexDesc
                    }.inObjectScope(.Container)
            case "texture-descriptor":
                let textureDesc = S3DXMLMTLTextureDescriptorNode().parse(container, elem: child)
                container.register(MTLTextureDescriptor.self, name: key!) { _ in
                    return textureDesc
                    }.inObjectScope(.Container)
            case "sampler-descriptor":
                let samplerDesc = S3DXMLMTLSamplerDescriptorNode().parse(container, elem: child)
                container.register(MTLSamplerDescriptor.self, name: key!) { _ in
                    return samplerDesc
                    }.inObjectScope(.Container)
            case "stencil-descriptor":
                let stencilDesc = S3DXMLMTLStencilDescriptorNode().parse(container, elem: child)
                container.register(MTLStencilDescriptor.self, name: key!) { _ in
                    return stencilDesc
                    }.inObjectScope(.Container)
            case "depth-stencil-descriptor":
                let depthStencilDesc = S3DXMLMTLDepthStencilDescriptorNode().parse(container, elem: child)
                container.register(MTLDepthStencilDescriptor.self, name: key!) { _ in
                    return depthStencilDesc
                    }.inObjectScope(.Container)
            case "render-pipeline-color-attachment-descriptor":
                let colorAttachmentDesc = S3DXMLMTLColorAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPipelineColorAttachmentDescriptor.self, name: key!) { _ in
                    return colorAttachmentDesc
                    }.inObjectScope(.Container)
            case "render-pipeline-descriptor":
                let renderPipelineDesc = S3DXMLMTLRenderPipelineDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPipelineDescriptor.self, name: key!) { _ in
                    return renderPipelineDesc
                    }.inObjectScope(.Container)
            case "compute-pipeline-descriptor":
                let computePipelineDesc = S3DXMLMTLComputePipelineDescriptorNode().parse(container, elem: child)
                container.register(MTLComputePipelineDescriptor.self, name: key!) { _ in
                    return computePipelineDesc
                    }.inObjectScope(.Container)
            case "clear-color":
                let clearColor = S3DXMLMTLClearColorNode().parse(container, elem: child)
                container.register(MTLClearColor.self, name: key!) { _ in
                    return clearColor
                }.inObjectScope(.Container)
            case "render-pass-color-attachment-descriptor":
                let renderPassColorAttachDesc = S3DXMLMTLRenderPassColorAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassColorAttachmentDescriptor.self, name: key!) { _ in
                    return renderPassColorAttachDesc
                }.inObjectScope(.Container)
            case "render-pass-depth-attachment-descriptor":
                let renderPassDepthAttachDesc = S3DXMLMTLRenderPassDepthAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassDepthAttachmentDescriptor.self, name: key!) { _ in
                    return renderPassDepthAttachDesc
                }.inObjectScope(.Container)
            case "render-pass-stencil-attachment-descriptor":
                let renderPassStencilAttachDesc = S3DXMLMTLRenderPassStencilAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassStencilAttachmentDescriptor.self, name: key!) { _ in
                    return renderPassStencilAttachDesc
                }.inObjectScope(.Container)
            case "render-pass-descriptor":
                let renderPassDescriptor = S3DXMLMTLRenderPassDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassDescriptor.self, name: key!) { _ in
                    return renderPassDescriptor
                }.inObjectScope(.Container)
            default:
                break
            }
        }
    }
    
    private func assembleRenderPassFactories(container: Container) {
        
        // TODO: evaluate whether these factories add value. or maybe there should be a separate container
        // user should read in base objects with XML, 
        // - then create resources for drawing (textures for render pass, etc)
        // - then resolve one of these higher order factories to create the final render pass objects
        // - then resolve a h/o RenderPassDescriptor factory to create the final render pass descriptor
        // - and finally, retain references to those objects within the scope of their controller/whatever
        
        // TODO: change these to accept the descriptor as input, & leave it up to the user to maintain object
        // TODO: enable updating properties on each? or leave that up to user?
        
        // MTLRenderPassColorAttachmentDescriptor
        
        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        // MTLRenderPassDepthAttachmentDescriptor
        
        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        // MTLRenderPassStencilAttachmentDescriptor
        
        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, key: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by key, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: key)!
            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        
        
    }
}
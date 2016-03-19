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

public class DescriptorManager {
    public var library: MTLLibrary // TODO: support multiple libraries?
    
    public var xsd: MetalXSD
    public var container: Container = Container()
    
    //TODO: consolidate vertex/fragment/compute functions as getMtlFunction()?
    public func getVertexFunction(id: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: id)!
    }
    
    public func getFragmentFunction(id: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: id)!
    }
    
    public func getComputeFunction(id: String) -> MTLFunction {
        return container.resolve(MTLFunction.self, name: id)!
    }
    
    public func getVertexDescriptor(id: String) -> MTLVertexDescriptor {
        return container.resolve(MTLVertexDescriptor.self, name: id)!
    }
    
    public func getTextureDescriptor(id: String) -> MTLTextureDescriptor {
        return container.resolve(MTLTextureDescriptor.self, name: id)!
    }
    
    public func getSamplerDescriptor(id: String) -> MTLSamplerDescriptor {
        return container.resolve(MTLSamplerDescriptor.self, name: id)!
    }
    
    public func getStencilDescriptor(id: String) -> MTLStencilDescriptor {
        return container.resolve(MTLStencilDescriptor.self, name: id)!
    }
    
    public func getDepthStencilDescriptor(id: String) -> MTLDepthStencilDescriptor {
        return container.resolve(MTLDepthStencilDescriptor.self, name: id)!
    }
    
    public func getColorAttachmentDescriptor(id: String) -> MTLRenderPipelineColorAttachmentDescriptor {
        return container.resolve(MTLRenderPipelineColorAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPipelineDescriptor(id: String) -> MTLRenderPipelineDescriptor {
        return container.resolve(MTLRenderPipelineDescriptor.self, name: id)!
    }
    
    public func getClearColor(id: String) -> MTLClearColor {
        return container.resolve(MTLClearColor.self, name: id)!
    }
    
    public func getRenderPassColorAttachmentDescriptor(id: String) -> MTLRenderPassColorAttachmentDescriptor {
        return container.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassDepthAttachmentDescriptor(id: String) -> MTLRenderPassDepthAttachmentDescriptor {
        return container.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassStencilAttachmentDescriptor(id: String) -> MTLRenderPassStencilAttachmentDescriptor {
        return container.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
    }
    
    public func getRenderPassDescriptor(id: String) -> MTLRenderPassDescriptor {
        return container.resolve(MTLRenderPassDescriptor.self, name: id)!
    }
    
    public func getComputePipelineDescriptor(id: String) -> MTLComputePipelineDescriptor {
        return container.resolve(MTLComputePipelineDescriptor.self, name: id)!
    }
    
    public init(library: MTLLibrary) {
        self.library = library
        self.container.register(MTLLibrary.self, name: "default") { _ in return library }.inObjectScope(.Container)
        
        // just parsing enum types from XSD for now
        let xmlData = MetalXSD.readXSD("MetalEnums")
        xsd = MetalXSD(data: xmlData)
        xsd.parseEnumTypes(container)
    }
    
    public func getMtlEnum(name: String, id: String) -> UInt {
        return container.resolve(MetalEnum.self, name: name)!.getValue(id)
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
            let id = child.attributes["id"]
            
            switch tag {
            case "vertex-function", "fragment-function", "compute-function":
                let mtlFunction = S3DXMLMTLFunctionNode(library: library).parse(container, elem: child)
                container.register(MTLFunction.self, name: id!) { _ in
                    return mtlFunction
                    }.inObjectScope(.Container)
            case "vertex-descriptor":
                let vertexDesc = S3DXMLMTLVertexDescriptorNode().parse(container, elem: child)
                container.register(MTLVertexDescriptor.self, name: id!) { _ in
                    return vertexDesc.copy() as! MTLVertexDescriptor
                    }.inObjectScope(.Container)
            case "texture-descriptor":
                let textureDesc = S3DXMLMTLTextureDescriptorNode().parse(container, elem: child)
                container.register(MTLTextureDescriptor.self, name: id!) { _ in
                    return textureDesc.copy() as! MTLTextureDescriptor
                    }.inObjectScope(.Container)
            case "sampler-descriptor":
                let samplerDesc = S3DXMLMTLSamplerDescriptorNode().parse(container, elem: child)
                container.register(MTLSamplerDescriptor.self, name: id!) { _ in
                    return samplerDesc.copy() as! MTLSamplerDescriptor
                    }.inObjectScope(.Container)
            case "stencil-descriptor":
                let stencilDesc = S3DXMLMTLStencilDescriptorNode().parse(container, elem: child)
                container.register(MTLStencilDescriptor.self, name: id!) { _ in
                    return stencilDesc.copy() as! MTLStencilDescriptor
                    }.inObjectScope(.Container)
            case "depth-stencil-descriptor":
                let depthStencilDesc = S3DXMLMTLDepthStencilDescriptorNode().parse(container, elem: child)
                container.register(MTLDepthStencilDescriptor.self, name: id!) { _ in
                    return depthStencilDesc.copy() as! MTLDepthStencilDescriptor
                    }.inObjectScope(.Container)
            case "render-pipeline-color-attachment-descriptor":
                let colorAttachmentDesc = S3DXMLMTLColorAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPipelineColorAttachmentDescriptor.self, name: id!) { _ in
                    return colorAttachmentDesc.copy() as! MTLRenderPipelineColorAttachmentDescriptor
                    }.inObjectScope(.Container)
            case "render-pipeline-descriptor":
                let renderPipelineDesc = S3DXMLMTLRenderPipelineDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPipelineDescriptor.self, name: id!) { _ in
                    return renderPipelineDesc.copy() as! MTLRenderPipelineDescriptor
                    }.inObjectScope(.Container)
            case "compute-pipeline-descriptor":
                let computePipelineDesc = S3DXMLMTLComputePipelineDescriptorNode().parse(container, elem: child)
                container.register(MTLComputePipelineDescriptor.self, name: id!) { _ in
                    return computePipelineDesc.copy() as! MTLComputePipelineDescriptor
                    }.inObjectScope(.Container)
            case "clear-color":
                let clearColor = S3DXMLMTLClearColorNode().parse(container, elem: child)
                container.register(MTLClearColor.self, name: id!) { _ in
                    return clearColor // struct (no need for copy)
                }.inObjectScope(.Container)
            case "render-pass-color-attachment-descriptor":
                let renderPassColorAttachDesc = S3DXMLMTLRenderPassColorAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassColorAttachmentDescriptor.self, name: id!) { _ in
                    return renderPassColorAttachDesc.copy() as! MTLRenderPassColorAttachmentDescriptor
                }.inObjectScope(.Container)
            case "render-pass-depth-attachment-descriptor":
                let renderPassDepthAttachDesc = S3DXMLMTLRenderPassDepthAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassDepthAttachmentDescriptor.self, name: id!) { _ in
                    return renderPassDepthAttachDesc.copy() as! MTLRenderPassDepthAttachmentDescriptor
                }.inObjectScope(.Container)
            case "render-pass-stencil-attachment-descriptor":
                let renderPassStencilAttachDesc = S3DXMLMTLRenderPassStencilAttachmentDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassStencilAttachmentDescriptor.self, name: id!) { _ in
                    return renderPassStencilAttachDesc.copy() as! MTLRenderPassStencilAttachmentDescriptor
                }.inObjectScope(.Container)
            case "render-pass-descriptor":
                let renderPassDescriptor = S3DXMLMTLRenderPassDescriptorNode().parse(container, elem: child)
                container.register(MTLRenderPassDescriptor.self, name: id!) { _ in
                    return renderPassDescriptor.copy() as! MTLRenderPassDescriptor
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
        
        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        // MTLRenderPassDepthAttachmentDescriptor
        
        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        // MTLRenderPassStencilAttachmentDescriptor
        
        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
            desc.texture = texture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
            // look up base color attachment by id, then copy and attach the texture
            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
            desc.texture = texture
            desc.resolveTexture = resolveTexture
            return desc
            }.inObjectScope(.None) // .None ensure the function always creates a new object
        
        
        
    }
}
//
//  MetalXSD
//
//
//  Created by David Conner on 10/12/15.
//
//

import Foundation
import Fuzi
import Swinject

public enum MetalNodeType: String {
    // TODO: add MTLLibrary node? how to specify method to retrieve libraries?
    // TODO: add MTLDevice node?  how to specify?
    case VertexFunction = "vertex-function"
    case FragmentFunction = "fragment-function"
    case ComputeFunction = "compute-function"
    case ClearColor = "clear-color"
    case VertexDescriptor = "vertex-descriptor"
    case VertexAttributeDescriptor = "vertex-attribute-descriptor"
    case VertexBufferLayoutDescriptor = "vertex-buffer-layout-descriptor"
    case TextureDescriptor = "texture-descriptor"
    case SamplerDescriptor = "sampler-descriptor"
    case StencilDescriptor = "stencil-descriptor"
    case DepthStencilDescriptor = "depth-stencil-descriptor"
    case RenderPipelineColorAttachmentDescriptor = "render-pipeline-color-attachment-descriptor"
    case RenderPipelineDescriptor = "render-pipeline-descriptor"
    case ComputePipelineDescriptor = "compute-pipeline-descriptor"
    case RenderPassColorAttachmentDescriptor = "render-pass-color-attachment-descriptor"
    case RenderPassDepthAttachmentDescriptor = "render-pass-depth-attachment-descriptor"
    case RenderPassStencilAttachmentDescriptor = "render-pass-stencil-attachment-descriptor"
    case RenderPassDescriptor = "render-pass-descriptor"
}

public class MetalParser {
    // NOTE: if device/library
    public var nodes: Container!
    
    // TODO: copy on resolve setting (false == never copy, true == always copy)
    
    public init(nodes: Container = Container()) {
        self.nodes = nodes
    }
    
    public init(parentContainer: Container) {
        self.nodes = Container(parent: parentContainer)
    }
    
    public func getMetalEnum(name: String, id: String) -> UInt {
        return nodes.resolve(MetalEnum.self, name: name)!.getValue(id)
    }
    
    public func getVertexFunction(id: String) -> FunctionNode {
        let n = nodes.resolve(FunctionNode.self, name: id)!
        return n.copy()
    }
    
    public func getFragmentFunction(id: String) -> FunctionNode {
        let n = nodes.resolve(FunctionNode.self, name: id)!
        return n.copy()
    }
    
    public func getComputeFunction(id: String) -> FunctionNode {
        let n = nodes.resolve(FunctionNode.self, name: id)!
        return n.copy()
    }
    
    public func getVertexDescriptor(id: String) -> MetalVertexDescriptorNode {
        let n = nodes.resolve(MetalVertexDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getTextureDescriptor(id: String) -> TextureDescriptorNode {
        return nodes.resolve(TextureDescriptorNode.self, name: id)!
    }
    
    public func getSamplerDescriptor(id: String) -> SamplerDescriptorNode {
        return nodes.resolve(SamplerDescriptorNode.self, name: id)!
    }

    public func getStencilDescriptor(id: String) -> StencilDescriptorNode {
        return nodes.resolve(StencilDescriptorNode.self, name: id)!
    }
    
//    public func getDepthStencilDescriptor(id: String) -> DepthStencilDescriptorNode {
//        return nodes.resolve(DepthStencilDescriptorNode.self, name: id)!
//    }
    
    public func getRenderPipelineColorAttachmentDescriptor(id: String) -> RenderPipelineColorAttachmentDescriptorNode {
        return nodes.resolve(RenderPipelineColorAttachmentDescriptorNode.self, name: id)!
    }

//    public func getRenderPipelineDescriptor(id: String) -> RenderPipelineDescriptorNode {
//        return nodes.resolve(RenderPipelineDescriptorNode.self, name: id)!
//    }
    
    public func getClearColor(id: String) -> ClearColorNode {
        return nodes.resolve(ClearColorNode.self, name: id)!
    }
    
    public func getRenderPassColorAttachmentDescriptor(id: String) -> RenderPassColorAttachmentDescriptorNode {
        return nodes.resolve(RenderPassColorAttachmentDescriptorNode.self, name: id)!
    }
    
    public func getRenderPassDepthAttachmentDescriptor(id: String) -> RenderPassDepthAttachmentDescriptorNode {
        return nodes.resolve(RenderPassDepthAttachmentDescriptorNode.self, name: id)!
    }
    
    public func getRenderPassStencilAttachmentDescriptor(id: String) -> RenderPassStencilAttachmentDescriptorNode {
        return nodes.resolve(RenderPassStencilAttachmentDescriptorNode.self, name: id)!
    }
    
//    public func getRenderPassDescriptor(id: String) -> RenderPassDescriptorNode {
//        return nodes.resolve(RenderPassDescriptorNode.self, name: id)!
//    }
    
//    public func getComputePipelineDescriptor(id: String) -> ComputePipelineDescriptorNode {
//        return nodes.resolve(ComputePipelineDescriptorNode.self, name: id)!
//    }
    
    // TODO: figure out how to break this out into parseNode() -> MetalNode
    // - however, the problem is that
    public func parseXML(xml: XMLDocument) {
        for elem in xml.root!.children {
            parseNode(elem)
        }
    }
    
    public func parseNode(elem: XMLElement) {
        let (tag, id, ref) = (elem.tag!, elem.attributes["id"], elem.attributes["ref"])
        
        if let nodeType = MetalNodeType(rawValue: tag) {
            
            switch nodeType {
            case .VertexFunction:
                let node = FunctionNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .FragmentFunction:
                let node = FunctionNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .ComputeFunction:
                let node = FunctionNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            // TODO: case: .OptionSet? : break
            case .VertexDescriptor:
                let node = MetalVertexDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .VertexAttributeDescriptor:
                let node = VertexAttributeDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .VertexBufferLayoutDescriptor:
                let node = VertexBufferLayoutDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .TextureDescriptor:
                let node = TextureDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .SamplerDescriptor:
                let node = SamplerDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .StencilDescriptor:
                let node = StencilDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .DepthStencilDescriptor: break
            case .RenderPipelineColorAttachmentDescriptor:
                let node = RenderPipelineColorAttachmentDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPipelineDescriptor: break
            case .ComputePipelineDescriptor: break
            case .ClearColor:
                let node = ClearColorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPassColorAttachmentDescriptor:
                let node = RenderPassColorAttachmentDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPassDepthAttachmentDescriptor:
                let node = RenderPassDepthAttachmentDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPassStencilAttachmentDescriptor:
                let node = RenderPassStencilAttachmentDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPassDescriptor: break
            default: break
            }
        }
    }

    public static func initMetalEnums(container: Container) -> Container {
        let xmlData = MetalXSD.readXSD("MetalEnums")
        let xsd = MetalXSD(data: xmlData)
        xsd.parseEnumTypes(container)
        return container
    }
    
    public static func initMetal(container: Container) -> Container {
        // TODO: decide whether or not to let the device persist for the lifetime of the top-level container
        // - many classes require the device (and for some, i think object id matters, like for MTLLibrary)
        let dev = MTLCreateSystemDefaultDevice()!
        let lib = dev.newDefaultLibrary()!
        container.register(MTLDevice.self, name: "default") { _ in
            return dev
            }.inObjectScope(.None)
        
        container.register(MTLLibrary.self, name: "default") { _ in
            return lib
            }.inObjectScope(.None)
        
        return container
    }
    
    public static func readXML(bundle: NSBundle, filename: String, bundleResourceName: String?) -> XMLDocument? {
        var resourceBundle: NSBundle = bundle
        if let resourceName = bundleResourceName {
            let bundleURL = bundle.URLForResource(resourceName, withExtension: "bundle")
            resourceBundle = NSBundle(URL: bundleURL!)!
        }
        
        let path = resourceBundle.pathForResource(filename, ofType: "xml")
        let data = NSData(contentsOfFile: path!)
        
        do {
            return try XMLDocument(data: data!)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
        return nil
    }
}

public class MetalEnum {
    var name: String
    var values: [String: UInt] = [:] // private?
    
    public init(elem: XMLElement) {
        values = [:]
        name = elem.attributes["name"]!
        let valuesSelector = "xs:restriction > xs:enumeration"
        for child in elem.css(valuesSelector) {
            let val = child.attributes["id"]!
            let key = child.attributes["value"]!
            self.values[key] = UInt(val)
        }
    }
    
    public func getValue(id: String) -> UInt {
        return values[id]!
    }
    
    //    public func convertToEnum(key: String, val: Int) -> AnyObject {
    //        switch key {
    //        case "mtlStorageAction": return MTLStorageMode(rawValue: UInt(val))!
    //        default: val
    //        }
    //    }
}

public class MetalXSD {
    public var xsd: XMLDocument?
    var enumTypes: [String: MetalEnum] = [:]
    
    public init(data: NSData) {
        do {
            xsd = try XMLDocument(data: data)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
    }
    
    public class func readXSD(filename: String) -> NSData {
        let bundle = NSBundle(forClass: MetalXSD.self)
        let path = bundle.pathForResource(filename, ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    public func parseEnumTypes(container: Container) {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        
        for enumChild in xsd!.css(enumTypesSelector) {
            let enumType = MetalEnum(elem: enumChild)
            container.register(MetalEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
    }
}



//
//    private func assembleRenderPassFactories(container: Container) {
//
//        // TODO: evaluate whether these factories add value. or maybe there should be a separate container
//        // user should read in base objects with XML,
//        // - then create resources for drawing (textures for render pass, etc)
//        // - then resolve one of these higher order factories to create the final render pass objects
//        // - then resolve a h/o RenderPassDescriptor factory to create the final render pass descriptor
//        // - and finally, retain references to those objects within the scope of their controller/whatever
//
//        // TODO: change these to accept the descriptor as input, & leave it up to the user to maintain object
//        // TODO: enable updating properties on each? or leave that up to user?
//
//        // MTLRenderPassColorAttachmentDescriptor
//
//        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
//            desc.texture = texture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//        container.register(MTLRenderPassColorAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassColorAttachmentDescriptor
//            desc.texture = texture
//            desc.resolveTexture = resolveTexture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//        // MTLRenderPassDepthAttachmentDescriptor
//
//        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
//            desc.texture = texture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//        container.register(MTLRenderPassDepthAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassDepthAttachmentDescriptor
//            desc.texture = texture
//            desc.resolveTexture = resolveTexture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//        // MTLRenderPassStencilAttachmentDescriptor
//
//        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
//            desc.texture = texture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//        container.register(MTLRenderPassStencilAttachmentDescriptor.self) { (r, id: String, texture: MTLTexture, resolveTexture: MTLTexture) in
//            // look up base color attachment by id, then copy and attach the texture
//            var desc = r.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: id)!
//            desc = desc.copy() as! MTLRenderPassStencilAttachmentDescriptor
//            desc.texture = texture
//            desc.resolveTexture = resolveTexture
//            return desc
//            }.inObjectScope(.None) // .None ensure the function always creates a new object
//
//
//
//    }
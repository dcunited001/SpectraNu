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
        let n = nodes.resolve(TextureDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getSamplerDescriptor(id: String) -> SamplerDescriptorNode {
        let n = nodes.resolve(SamplerDescriptorNode.self, name: id)!
        return n.copy()
    }

    public func getStencilDescriptor(id: String) -> StencilDescriptorNode {
        let n = nodes.resolve(StencilDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getDepthStencilDescriptor(id: String) -> DepthStencilDescriptorNode {
        let n = nodes.resolve(DepthStencilDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getRenderPipelineColorAttachmentDescriptor(id: String) -> RenderPipelineColorAttachmentDescriptorNode {
        let n = nodes.resolve(RenderPipelineColorAttachmentDescriptorNode.self, name: id)!
        return n.copy()
    }

    public func getRenderPipelineDescriptor(id: String) -> RenderPipelineDescriptorNode {
        let n = nodes.resolve(RenderPipelineDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getClearColor(id: String) -> ClearColorNode {
        let n = nodes.resolve(ClearColorNode.self, name: id)!
        return n.copy()
    }
    
    public func getRenderPassColorAttachmentDescriptor(id: String) -> RenderPassColorAttachmentDescriptorNode {
        let n = nodes.resolve(RenderPassColorAttachmentDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getRenderPassDepthAttachmentDescriptor(id: String) -> RenderPassDepthAttachmentDescriptorNode {
        let n = nodes.resolve(RenderPassDepthAttachmentDescriptorNode.self, name: id)!
        return n.copy()
    }
    
    public func getRenderPassStencilAttachmentDescriptor(id: String) -> RenderPassStencilAttachmentDescriptorNode {
        let n = nodes.resolve(RenderPassStencilAttachmentDescriptorNode.self, name: id)!
        return n.copy()
    }
    
//    public func getRenderPassDescriptor(id: String) -> RenderPassDescriptorNode {
//        return nodes.resolve(RenderPassDescriptorNode.self, name: id)!
//    }
    
    public func getComputePipelineDescriptor(id: String) -> ComputePipelineDescriptorNode {
        return nodes.resolve(ComputePipelineDescriptorNode.self, name: id)!
    }
    
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
            case .DepthStencilDescriptor:
                let node = DepthStencilDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPipelineColorAttachmentDescriptor:
                let node = RenderPipelineColorAttachmentDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .RenderPipelineDescriptor:
                let node = RenderPipelineDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
            case .ComputePipelineDescriptor:
                let node = ComputePipelineDescriptorNode(nodes: nodes, elem: elem)
                if (node.id != nil) { node.register(nodes, objectScope: .None) }
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
//                let node = RenderPassDescriptorNode(nodes: nodes, elem: elem)
//                if (node.id != nil) { node.register(nodes, objectScope: .None) }
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
    
    // TODO: remove this, since both are only used on generate()
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

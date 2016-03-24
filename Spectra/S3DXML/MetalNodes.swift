//
//  S3DXML.swift
//  Pods
//
//  Created by David Conner on 10/12/15.
//
//

import Foundation
import Metal
import Fuzi
import Swinject

public protocol S3DXMLNodeParser {
    typealias NodeType
    
    func parse(container: Container, elem: XMLElement, options: [String: AnyObject]) -> NodeType
}

// PullbackTuple: not really sure that 'pullback' is the right term here ...
// - but i am trying to specify a tree-like structure with options
//   which allows one to dynamically retrieve/create MTL objects
//   by overlaying a construction on top of a category that allows
//   several paths (or morphisms) to the final MTL object (the terminal object?)
public typealias SpectraInjected = (containers: [String: Container], options: [String: Any])

// TODO: rename this? InputTransformClosure?
public typealias MetalNodeInjector = (SpectraInjected) -> SpectraInjected

// TODO: switch to format similar to SpectraXML
// - maybe? these objects are all easily copyable
public protocol MetalNode {
    typealias NodeType
    typealias MTLType
    
    var id: String? { get set }
    init() // adding this blank initializer allows me to work with Self() in RenderPassAttachmentDescriptorNode extension
    init(nodes: Container, elem: XMLElement)
    func parseXML(nodes: Container, elem: XMLElement)
    func generate(inj: SpectraInjected,
        injector: MetalNodeInjector?) -> MTLType
    func register(nodes: Container, objectScope: ObjectScope)
    func copy() -> NodeType
}

extension MetalNode {
    public func register(nodes: Container, objectScope: ObjectScope = .None) {
        let nodeCopy = self.copy()
        nodes.register(NodeType.self, name: self.id!) { _ in
            return nodeCopy
            }.inObjectScope(objectScope)
    }
    
    // resolves a metal device, either from options or container/options
    // - these resolve functions are used when generating nodes
    public func resolveMtlDevice(inj: SpectraInjected) -> SpectraInjected {
        if let device = inj.options["device"] as? MTLDevice {
            return inj
        } else {
            // get device from container/key
            var ninj = inj
            let containerKey = ninj.options["metal_container"] as? String ?? "metal"
            let deviceId = ninj.options["device_id"] as? String ?? "default"
            let metalContainer = ninj.containers[containerKey]!
            ninj.options["device"] = metalContainer.resolve(MTLDevice.self, name: deviceId) ?? MTLCreateSystemDefaultDevice()!
            return ninj
        }
    }
    
    // resolves a metal library, either from: 
    // - a library found in the options
    // - or a library resolved from a container, the location of which is specified in options
    public func resolveMtlLibrary(inj: SpectraInjected) -> SpectraInjected {
        if let library = inj.options["library"] as? MTLLibrary {
            return inj
        } else {
            var ninj = inj
            let device = resolveMtlDevice(ninj).options["device"] as! MTLDevice
            let containerKey = ninj.options["metal_container"] as? String ?? "metal"
            let libraryId = ninj.options["library_id"] as? String ?? "default"
            let metalContainer = ninj.containers[containerKey]!
            ninj.options["library"] = metalContainer.resolve(MTLLibrary.self, name: libraryId) ?? device.newDefaultLibrary()
            return ninj
        }
    }
}

// TODO: add MTLLibrary node? how to specify method to retrieve libraries?
//public class MetalLibraryNode: MetalNode {
//    public typealias NodeType = MTLLibrary
//    
//    init() {
//        
//    }
//    
//    public required init(nodes: Container, elem: XMLElement) {
//        parseXML(nodes, elem: elem)
//    }
//}

public class FunctionNode: MetalNode {
    public typealias NodeType = FunctionNode
    public typealias MTLType = MTLFunction
    
    public var id: String?
    public var name: String?
    public var type: String?
    // TODO: allow library to be specified?
    // public var library: String = "default"
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        self.type = elem.tag!
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["name"] { self.name = val }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector? = nil) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let library = resolveMtlLibrary(ninj).options["library"] as! MTLLibrary
        return library.newFunctionWithName(self.name!)!
    }
    
    public func copy() -> NodeType {
        let cp = FunctionNode()
        cp.id = self.id
        cp.name = self.name
        cp.type = self.type
        return cp
    }
}

public class MetalVertexDescriptorNode: MetalNode {
    public typealias NodeType = MetalVertexDescriptorNode
    public typealias MTLType = MTLVertexDescriptor
    
    public var id: String?
    public var attributes: [VertexAttributeDescriptorNode] = []
    public var layouts: [VertexBufferLayoutDescriptorNode] = []
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        
        let attributeDescSelector = "vertex-attribute-descriptors > vertex-attribute-descriptor"
        for (idx, el) in elem.css(attributeDescSelector).enumerate() {
            // TODO: retrieve if previously defined in nodes
            let node = VertexAttributeDescriptorNode(nodes: nodes, elem: el)
            self.attributes.append(node)
        }
        
        let bufferLayoutDescSelector = "vertex-buffer-layout-descriptors > vertex-buffer-layout-descriptor"
        for (idx, el) in elem.css(bufferLayoutDescSelector).enumerate() {
            // TODO: retrieve if previously defined in nodes
            let node = VertexBufferLayoutDescriptorNode(nodes: nodes, elem: el)
            self.layouts.append(node)
        }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector? = nil) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = MTLType()
        // TODO: reduce over attributes & layouts.  merge injected.options?
        for (idx, node) in self.attributes.enumerate() {
            //TODO: should injector be nil for nested objects? with option to read from inj.options?
            let attrDesc = node.generate(ninj, injector: nil)
            desc.attributes[idx] = attrDesc
        }
        for (idx, node) in self.layouts.enumerate() {
            let layoutDesc = node.generate(ninj, injector: nil)
            desc.layouts[idx] = layoutDesc
        }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = NodeType()
        cp.attributes = self.attributes.map { $0.copy() }
        cp.layouts = self.layouts.map { $0.copy() }
        return cp
    }
    
}

public class VertexAttributeDescriptorNode: MetalNode {
    public typealias NodeType = VertexAttributeDescriptorNode
    public typealias MTLType = MTLVertexAttributeDescriptor
    
    public var id: String?
    public var format: MTLVertexFormat?
    public var offset: Int?
    public var bufferIndex: Int?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let format = elem.attributes["format"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlVertexFormat")!
            let enumVal = mtlEnum.getValue(format)
            self.format = MTLVertexFormat(rawValue: enumVal)!
        }
        if let val = elem.attributes["offset"] { self.offset = Int(val)! }
        if let val = elem.attributes["bufferIndex"] { self.bufferIndex = Int(val)! }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = MTLType()
        if let val = self.format { desc.format = val }
        if let val = self.offset { desc.offset = val }
        if let val = self.bufferIndex { desc.bufferIndex = val }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.format = self.format
        cp.offset = self.offset
        cp.bufferIndex = self.bufferIndex
        return cp
    }
}

public class VertexBufferLayoutDescriptorNode: MetalNode {
    public typealias NodeType = VertexBufferLayoutDescriptorNode
    public typealias MTLType = MTLVertexBufferLayoutDescriptor
    
    public var id: String?
    public var stride: Int?
    public var stepFunction: MTLVertexStepFunction?
    public var stepRate: Int?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        let stride = elem.attributes["stride"]!
        self.stride = Int(stride)!
        
        if let val = elem.attributes["id"] { self.id = val }
        if let stepFunction = elem.attributes["step-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlVertexStepFunction")!
            let enumVal = mtlEnum.getValue(stepFunction)
            self.stepFunction = MTLVertexStepFunction(rawValue: enumVal)!
        }
        if let stepRate = elem.attributes["step-rate"] { self.stepRate = Int(stepRate)! }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = MTLType()
        desc.stride = self.stride!
        if let val = self.stepFunction { desc.stepFunction = val }
        if let val = self.stepRate { desc.stepRate = val }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.stride = self.stride
        cp.stepFunction = self.stepFunction
        cp.stepRate = self.stepRate
        return cp
    }
}

public class TextureDescriptorNode: MetalNode {
    public typealias NodeType = TextureDescriptorNode
    public typealias MTLType = MTLTextureDescriptor
    
    public var id: String?
    public var textureType: MTLTextureType?
    public var pixelFormat: MTLPixelFormat?
    public var width: Int?
    public var height: Int?
    public var depth: Int?
    public var mipmapLevelCount: Int?
    public var sampleCount: Int?
    public var arrayLength: Int?
    public var resourceOptions: MTLResourceOptions?
    public var cpuCacheMode: MTLCPUCacheMode?
    public var storageMode: MTLStorageMode?
    public var usage: MTLTextureUsage?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        
        if let val = elem.attributes["texture-type"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlTextureType")!
            let enumVal = mtlEnum.getValue(val)
            self.textureType = MTLTextureType(rawValue: enumVal)!
        }
        if let val = elem.attributes["pixel-format"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlPixelFormat")!
            let enumVal = mtlEnum.getValue(val)
            self.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let val = elem.attributes["width"] { self.width = Int(val)! }
        if let val = elem.attributes["height"] { self.height = Int(val)! }
        if let val = elem.attributes["depth"] { self.depth = Int(val)! }
        if let val = elem.attributes["mipmap-level-count"] { self.mipmapLevelCount = Int(val)! }
        if let val = elem.attributes["sample-count"] { self.sampleCount = Int(val)! }
        if let val = elem.attributes["array-length"] { self.arrayLength = Int(val)! }
        
        //TODO: resource options is an option set type, haven't decided on XML specification
        if let val = elem.attributes["cpu-cache-mode"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCpuCacheMode")!
            let enumVal = mtlEnum.getValue(val)
            self.cpuCacheMode = MTLCPUCacheMode(rawValue: enumVal)!
        }
        if let val = elem.attributes["storage-mode"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStorageMode")!
            let enumVal = mtlEnum.getValue(val)
            self.storageMode = MTLStorageMode(rawValue: enumVal)!
        }
        //TODO: usage is an option set type, haven't decided on XML specification
        //        if let val = elem.attributes["usage"] {
        //            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlTextureUsage")!
        //            let enumVal = mtlEnum.getValue(val)
        //            texDesc.usage = MTLTextureUsage(rawValue: enumVal)
        //        }
        
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = MTLType()
        if let val = self.textureType { desc.textureType = val }
        if let val = self.pixelFormat { desc.pixelFormat = val }
        if let val = self.width { desc.width = val }
        if let val = self.height { desc.height = val }
        if let val = self.depth { desc.depth = val }
        if let val = self.mipmapLevelCount { desc.mipmapLevelCount = val }
        if let val = self.sampleCount { desc.sampleCount = val }
        if let val = self.arrayLength { desc.arrayLength = val }
        if let val = self.resourceOptions { desc.resourceOptions = val }
        if let val = self.cpuCacheMode { desc.cpuCacheMode = val }
        if let val = self.cpuCacheMode { desc.cpuCacheMode = val }
        if let val = self.storageMode { desc.storageMode = val }
        if let val = self.usage { desc.usage = val }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = NodeType()
        cp.textureType = self.textureType
        cp.pixelFormat = self.pixelFormat
        cp.width = self.width
        cp.height = self.height
        cp.depth = self.depth
        cp.mipmapLevelCount = self.mipmapLevelCount
        cp.sampleCount = self.sampleCount
        cp.arrayLength = self.arrayLength
        cp.resourceOptions = self.resourceOptions
        cp.cpuCacheMode = self.cpuCacheMode
        cp.storageMode = self.storageMode
        cp.usage = self.usage
        return cp
    }
}

public class SamplerDescriptorNode: MetalNode {
    public typealias NodeType = SamplerDescriptorNode
    public typealias MTLType = MTLSamplerDescriptor

    public var id: String?
    public var label: String?
    public var minFilter: MTLSamplerMinMagFilter?
    public var magFilter: MTLSamplerMinMagFilter?
    public var mipFilter: MTLSamplerMipFilter?
    public var maxAnisotropy: Int?
    public var rAddressMode: MTLSamplerAddressMode?
    public var tAddressMode: MTLSamplerAddressMode?
    public var sAddressMode: MTLSamplerAddressMode?
    public var normalizedCoordinates: Bool?
    public var lodMinClamp: Float?
    public var lodMaxClamp: Float?
    public var lodAverage: Bool?
    public var compareFunction: MTLCompareFunction?
    
    public required init() {
        // required for copy
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let label = elem.attributes["label"] { self.label = label }
        if let val = elem.attributes["min-filter"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerMinMagFilter")!
            let enumVal = mtlEnum.getValue(val)
            self.minFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let val = elem.attributes["mag-filter"]{
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerMinMagFilter")!
            let enumVal = mtlEnum.getValue(val)
            self.magFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let val = elem.attributes["mip-filter"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerMipFilter")!
            let enumVal = mtlEnum.getValue(val)
            self.mipFilter = MTLSamplerMipFilter(rawValue: enumVal)!
        }
        if let val = elem.attributes["max-anisotropy"] { self.maxAnisotropy = Int(val)! }
        if let val = elem.attributes["s-address-mode"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerAddressMode")!
            let enumVal = mtlEnum.getValue(val)
            self.sAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let val = elem.attributes["r-address-mode"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerAddressMode")!
            let enumVal = mtlEnum.getValue(val)
            self.rAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let val = elem.attributes["t-address-mode"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlSamplerAddressMode")!
            let enumVal = mtlEnum.getValue(val)
            self.tAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let val = elem.attributes["normalized-coordinates"] { self.normalizedCoordinates = NSString(string: val).boolValue }
        if let val = elem.attributes["lod-min-clamp"] { self.lodMinClamp = Float(val)! }
        if let val = elem.attributes["lod-max-clamp"] { self.lodMaxClamp = Float(val)! }
        if let val = elem.attributes["lod-average"] { self.lodAverage = NSString(string: val).boolValue }
        if let val = elem.attributes["compare-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCompareFunction")!
            let enumVal = mtlEnum.getValue(val)
            self.compareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = MTLType()
        if let val = self.label { desc.label = val }
        if let val = self.minFilter { desc.minFilter = val }
        if let val = self.magFilter { desc.magFilter = val }
        if let val = self.mipFilter { desc.mipFilter = val }
        if let val = self.maxAnisotropy { desc.maxAnisotropy = val }
        if let val = self.rAddressMode { desc.rAddressMode = val }
        if let val = self.tAddressMode { desc.tAddressMode = val }
        if let val = self.sAddressMode { desc.sAddressMode = val }
        if let val = self.normalizedCoordinates { desc.normalizedCoordinates = val }
        if let val = self.lodMinClamp { desc.lodMinClamp = val }
        if let val = self.lodMaxClamp { desc.lodMaxClamp = val }
        #if os(iOS)
        if let val = self.lodAverage { desc.lodAverage = val }
        #endif
        if let val = self.compareFunction { desc.compareFunction = val }
        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.label = self.label
        cp.minFilter = self.minFilter
        cp.magFilter = self.magFilter
        cp.mipFilter = self.mipFilter
        cp.maxAnisotropy = self.maxAnisotropy
        cp.rAddressMode = self.rAddressMode
        cp.tAddressMode = self.tAddressMode
        cp.sAddressMode = self.sAddressMode
        cp.normalizedCoordinates = self.normalizedCoordinates
        cp.lodMinClamp = self.lodMinClamp
        cp.lodMaxClamp = self.lodMaxClamp
        cp.lodAverage = self.lodAverage
        cp.compareFunction = self.compareFunction
        return cp
    }
}

public class StencilDescriptorNode: MetalNode {
    public typealias NodeType = StencilDescriptorNode
    public typealias MTLType = MTLStencilDescriptor

    public var id: String?
    public var stencilCompareFunction: MTLCompareFunction?
    public var stencilFailureOperation: MTLStencilOperation?
    public var depthFailureOperation: MTLStencilOperation?
    public var depthStencilPassOperation: MTLStencilOperation?
    public var readMask: UInt32?
    public var writeMask: UInt32?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["stencil-compare-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCompareFunction")!
            let enumVal = mtlEnum.getValue(val)
            self.stencilCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let val = elem.attributes["stencil-failure-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(val)
            self.stencilFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let val = elem.attributes["depth-failure-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(val)
            self.depthFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let val = elem.attributes["depth-stencil-pass-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(val)
            self.depthStencilPassOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let val = elem.attributes["read-mask"] { self.readMask = UInt32(val)! }
        if let val = elem.attributes["write-mask"] { self.writeMask = UInt32(val)! }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()
        if let val = self.stencilCompareFunction { desc.stencilCompareFunction = val }
        if let val = self.stencilFailureOperation { desc.stencilFailureOperation = val }
        if let val = self.depthFailureOperation { desc.depthFailureOperation = val }
        if let val = self.depthStencilPassOperation { desc.depthStencilPassOperation = val }
        if let val = self.readMask { desc.readMask = val }
        if let val = self.writeMask { desc.writeMask = val }
        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.stencilCompareFunction = self.stencilCompareFunction
        cp.stencilFailureOperation = self.stencilFailureOperation
        cp.depthFailureOperation = self.depthFailureOperation
        cp.depthStencilPassOperation = self.depthStencilPassOperation
        cp.readMask = self.readMask
        cp.writeMask = self.writeMask
        return cp
    }
}

public class DepthStencilDescriptorNode: MetalNode {
    public typealias NodeType = DepthStencilDescriptorNode
    public typealias MTLType = MTLDepthStencilDescriptor
    
    public var id: String?
    public var label: String?
    public var depthCompareFunction: MTLCompareFunction?
    public var depthWriteEnabled: Bool?
    public var frontFaceStencil: StencilDescriptorNode?
    public var backFaceStencil: StencilDescriptorNode?

    public required init() {
        
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["label"] { self.label = val }
        if let val = elem.attributes["depth-write-enabled"] { self.depthWriteEnabled = NSString(string: val).boolValue }
        
        if let val = elem.attributes["depth-compare-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCompareFunction")!
            let enumVal = mtlEnum.getValue(val)
            self.depthCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        
        if let frontFaceTag = elem.firstChild(tag: "front-face-stencil") {
            if let frontFaceName = frontFaceTag.attributes["ref"] {
                self.frontFaceStencil = nodes.resolve(StencilDescriptorNode.self, name: frontFaceName)!
            } else {
                let frontFaceStencil = StencilDescriptorNode(nodes: nodes, elem: frontFaceTag)
                self.frontFaceStencil = frontFaceStencil
                
                if let id = frontFaceTag.attributes["id"] {
                    nodes.register(StencilDescriptorNode.self, name: id) { _ in
                        return frontFaceStencil
                        }.inObjectScope(.None)
                }
            }
        }
        
        if let backFaceTag = elem.firstChild(tag: "back-face-stencil") {
            if let backFaceName = backFaceTag.attributes["ref"] {
                self.backFaceStencil = nodes.resolve(StencilDescriptorNode.self, name: backFaceName)!
            } else {
                let backFaceStencil = StencilDescriptorNode(nodes: nodes, elem: backFaceTag)
                self.backFaceStencil = backFaceStencil
                
                if let id = backFaceTag.attributes["id"] {
                    nodes.register(StencilDescriptorNode.self, name: id) { _ in
                        return backFaceStencil
                        }.inObjectScope(.None)
                }
            }
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()
        if let val = self.label { desc.label = val }
        if let val = self.depthCompareFunction { desc.depthCompareFunction = val }
        if let val = self.depthWriteEnabled { desc.depthWriteEnabled = val }
        //TODO: generate
//        if let val = self.frontFaceStencil { desc.frontFaceStencil = val }
//        if let val = self.backFaceStencil { desc.backFaceStencil = val }
        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.label = self.label
        cp.depthCompareFunction = self.depthCompareFunction
        cp.depthWriteEnabled = self.depthWriteEnabled
        cp.frontFaceStencil = self.frontFaceStencil?.copy()
        cp.backFaceStencil = self.backFaceStencil?.copy()
        return cp
    }
}

public class RenderPipelineColorAttachmentDescriptorNode: MetalNode {
    public typealias NodeType = RenderPipelineColorAttachmentDescriptorNode
    public typealias MTLType = MTLRenderPipelineColorAttachmentDescriptor

    public var id: String?
    public var pixelFormat: MTLPixelFormat?
    public var blendingEnabled: Bool?
    public var sourceRGBBlendFactor: MTLBlendFactor?
    public var destinationRGBBlendFactor: MTLBlendFactor?
    public var rgbBlendOperation: MTLBlendOperation?
    public var sourceAlphaBlendFactor: MTLBlendFactor?
    public var destinationAlphaBlendFactor: MTLBlendFactor?
    public var alphaBlendOperation: MTLBlendOperation?
    //TODO: public var writeMask: MTLColorWriteMask?
    
    public required init() {
        // required for copy
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["blending-enabled"] { self.blendingEnabled = NSString(string: val).boolValue }
        if let val = elem.attributes["pixel-format"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlPixelFormat")!
            let enumVal = mtlEnum.getValue(val)
            self.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let val = elem.attributes["source-rgb-blend-factor"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendFactor")!
            let enumVal = mtlEnum.getValue(val)
            self.sourceRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let val = elem.attributes["destination-rgb-blend-factor"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendFactor")!
            let enumVal = mtlEnum.getValue(val)
            self.destinationRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let val = elem.attributes["rgb-blend-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendOperation")!
            let enumVal = mtlEnum.getValue(val)
            self.rgbBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
        if let val = elem.attributes["source-alpha-blend-factor"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendFactor")!
            let enumVal = mtlEnum.getValue(val)
            self.sourceAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let val = elem.attributes["destination-alpha-blend-factor"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendFactor")!
            let enumVal = mtlEnum.getValue(val)
            self.destinationAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let val = elem.attributes["alpha-blend-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlBlendOperation")!
            let enumVal = mtlEnum.getValue(val)
            self.alphaBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()
        if let val = self.pixelFormat { desc.pixelFormat = val }
        if let val = self.blendingEnabled { desc.blendingEnabled = val }
        if let val = self.sourceRGBBlendFactor { desc.sourceRGBBlendFactor = val }
        if let val = self.destinationRGBBlendFactor { desc.destinationRGBBlendFactor = val }
        if let val = self.rgbBlendOperation { desc.rgbBlendOperation = val }
        if let val = self.sourceAlphaBlendFactor { desc.sourceAlphaBlendFactor = val }
        if let val = self.destinationAlphaBlendFactor { desc.destinationAlphaBlendFactor = val }
        if let val = self.alphaBlendOperation { desc.alphaBlendOperation = val }
        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.pixelFormat = self.pixelFormat
        cp.blendingEnabled = self.blendingEnabled
        cp.sourceRGBBlendFactor = self.sourceRGBBlendFactor
        cp.destinationRGBBlendFactor = self.destinationRGBBlendFactor
        cp.rgbBlendOperation = self.rgbBlendOperation
        cp.sourceAlphaBlendFactor = self.sourceAlphaBlendFactor
        cp.destinationAlphaBlendFactor = self.destinationAlphaBlendFactor
        cp.alphaBlendOperation = self.alphaBlendOperation
        return cp
    }
}

public class RenderPipelineDescriptorNode: MetalNode {
    public typealias NodeType = RenderPipelineDescriptorNode
    public typealias MTLType = MTLRenderPipelineDescriptor

    public var id: String?
    public var vertexFunction: FunctionNode?
    public var fragmentFunction: FunctionNode?
    public var vertexDescriptor: VertexDescriptorNode?
    public var colorAttachmentDescriptors: [RenderPipelineColorAttachmentDescriptorNode] = []
    public var label: String?
    public var sampleCount: Int?
    public var alphaToCoverageEnabled: Bool?
    public var alphaToOneEnabled: Bool?
    public var rasterizationEnabled: Bool?
    public var depthAttachmentPixelFormat: MTLPixelFormat?
    public var stencilAttachmentPixelFormat: MTLPixelFormat?
    
    public required init() {

    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["label"] { self.label = val }
        if let val = elem.attributes["sample-count"] { self.sampleCount = Int(val)! }
        if let val = elem.attributes["alpha-to-coverage-enabled"] { self.alphaToCoverageEnabled = NSString(string: val).boolValue }
        if let val = elem.attributes["alpha-to-one-enabled"] {
            self.alphaToOneEnabled = NSString(string: val).boolValue
        }
        if let val = elem.attributes["rasterization-enabled"] {
            self.rasterizationEnabled = NSString(string: val).boolValue
        }
        if let val = elem.attributes["depth-attachment-pixel-format"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlPixelFormat")!
            let enumVal = mtlEnum.getValue(val)
            self.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let val = elem.attributes["stencil-attachment-pixel-format"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlPixelFormat")!
            let enumVal = mtlEnum.getValue(val)
            self.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }

        if let vertexFunctionTag = elem.firstChild(tag: "vertex-function") {
            if let vertexFunctionName = vertexFunctionTag.attributes["ref"] {
                self.vertexFunction = nodes.resolve(FunctionNode.self, name: vertexFunctionName)
            } else {
                //TODO: attribute tag for library
                //TODO: set function type
                let vertexFunction = FunctionNode(nodes: nodes, elem: vertexFunctionTag)
                self.vertexFunction = vertexFunction

                if let id = vertexFunctionTag.attributes["id"] {
                    nodes.register(FunctionNode.self, name: id) { _ in
                        return vertexFunction
                        }.inObjectScope(.None)
                }
            }
        }

        if let fragmentFunctionTag = elem.firstChild(tag: "fragment-function") {
            if let fragmentFunctionName = fragmentFunctionTag.attributes["ref"] {
                self.fragmentFunction = nodes.resolve(FunctionNode.self, name: fragmentFunctionName)
            } else {
                //TODO: attribute tag for library
                //TODO: set function type
                let fragmentFunction = FunctionNode(nodes: nodes, elem: fragmentFunctionTag)
                self.fragmentFunction = fragmentFunction

                if let id = fragmentFunctionTag.attributes["id"] {
                    nodes.register(FunctionNode.self, name: id) { _ in
                        return fragmentFunction
                        }.inObjectScope(.None)
                }
            }
        }

        if let vertexDescTag = elem.firstChild(tag: "vertex-descriptor") {
            if let vertexDescName = vertexDescTag.attributes["ref"] {
                self.vertexDescriptor = nodes.resolve(VertexDescriptorNode.self, name: vertexDescName)
            } else {
                let vertexDesc = VertexDescriptorNode(nodes: nodes, elem: vertexDescTag)
                self.vertexDescriptor = vertexDesc

                if let id = vertexDescTag.attributes["id"] {
                    nodes.register(VertexDescriptorNode.self, name: id) { _ in
                        return vertexDesc
                        }.inObjectScope(.None)
                }
            }
        }

        let colorAttachSelector = "color-attachment-descriptors > color-attachment-descriptor"
        for (idx, el) in elem.css(colorAttachSelector).enumerate() {
            if let colorAttachName = el.attributes["ref"] {
                let colorAttachDesc = nodes.resolve(RenderPipelineColorAttachmentDescriptorNode.self, name: colorAttachName)!
                self.colorAttachmentDescriptors.append(colorAttachDesc)
            } else {
                let colorAttachDesc = RenderPipelineColorAttachmentDescriptorNode(nodes: nodes, elem: el)
                self.colorAttachmentDescriptors.append(colorAttachDesc)
                
                if let id = el.attributes["id"] {
                    nodes.register(RenderPipelineColorAttachmentDescriptorNode.self, name: id) { _ in
                        return colorAttachDesc
                        }.inObjectScope(.None)
                }
            }
        }

    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()

        // TODO: generate render pipeline descriptor
        
        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.vertexFunction = self.vertexFunction?.copy()
        cp.fragmentFunction = self.fragmentFunction?.copy()
        cp.vertexDescriptor = self.vertexDescriptor?.copy()
        cp.colorAttachmentDescriptors = self.colorAttachmentDescriptors.map { $0.copy() }
        cp.label = self.label
        cp.sampleCount = self.sampleCount
        cp.alphaToCoverageEnabled = self.alphaToCoverageEnabled
        cp.alphaToOneEnabled = self.alphaToOneEnabled
        cp.rasterizationEnabled = self.rasterizationEnabled
        cp.depthAttachmentPixelFormat = self.depthAttachmentPixelFormat
        cp.stencilAttachmentPixelFormat = self.stencilAttachmentPixelFormat
        return cp
    }
}

public class ComputePipelineDescriptorNode: MetalNode {
    public typealias NodeType = ComputePipelineDescriptorNode
    public typealias MTLType = MTLComputePipelineDescriptor

    public var id: String?
    public var computeFunction: FunctionNode?
    public var label: String?
    public var threadGroupSizeIsMultipleOfThreadExecutionWidth: Bool?

    public required init() {

    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["label"] { self.label = val }
        if let val = elem.attributes["thread-group-size-is-multiple-of-thread-execution-width"] { self.threadGroupSizeIsMultipleOfThreadExecutionWidth = NSString(string: val).boolValue }
        
        if let computeFunctionTag = elem.firstChild(tag: "compute-function") {
            if let computeFunctionName = computeFunctionTag.attributes["ref"] {
                self.computeFunction = nodes.resolve(FunctionNode.self, name: computeFunctionName)
            } else {
                //TODO: attribute tag for library
                //TODO: set function type
                let computeFunction = FunctionNode(nodes: nodes, elem: computeFunctionTag)
                self.computeFunction = computeFunction

                if let id = computeFunctionTag.attributes["id"] {
                    nodes.register(FunctionNode.self, name: id) { _ in
                        return computeFunction
                        }.inObjectScope(.None)
                }
            }
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()

        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.computeFunction = self.computeFunction
        cp.label = self.label
        cp.threadGroupSizeIsMultipleOfThreadExecutionWidth = self.threadGroupSizeIsMultipleOfThreadExecutionWidth
        return cp
    }
}

public class ClearColorNode: MetalNode {
    public typealias NodeType = ClearColorNode
    public typealias MTLType = MTLClearColor

    public var id: String?
    public var red: Double?
    public var blue: Double?
    public var green: Double?
    public var alpha: Double?
    
    public required init() {
        // required for copy
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        if let val = elem.attributes["red"] { self.red = Double(val)! }
        if let val = elem.attributes["green"] { self.green = Double(val)! }
        if let val = elem.attributes["blue"] { self.blue = Double(val)! }
        if let val = elem.attributes["alpha"] { self.alpha = Double(val)! }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        return MTLClearColor(red: self.red!, green: self.green!, blue: self.blue!, alpha: self.alpha!)
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.id = self.id
        cp.red = self.red
        cp.green = self.green
        cp.blue = self.blue
        cp.alpha = self.alpha
        return cp
    }
}

public protocol RenderPassAttachmentDescriptorNode: class {
    associatedtype MTLType: MTLRenderPassAttachmentDescriptor
    
    // TODO: decide on texture descriptor node here? or just assuming this will be bundled in with the generator?
    var texture: TextureDescriptorNode? { get set }
    var level: Int? { get set }
    var slice: Int? { get set }
    var depthPlane: Int? { get set }
    
    var loadAction: MTLLoadAction? { get set }
    var storeAction: MTLStoreAction? { get set }
    
    // TODO: decide on texture descriptor node here? or just assuming this will be bundled in with the generator?
    var resolveTexture: TextureDescriptorNode? { get set }
    var resolveLevel: Int? { get set }
    var resolveSlice: Int? { get set }
    var resolveDepthPlane: Int? { get set }
    
    func parseRenderPassAttachmentXML(nodes: Container, elem: XMLElement)
    func generateRenderPassAttachment(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType
    func copyRenderPassAttachment() -> Self
}

extension RenderPassAttachmentDescriptorNode where Self: MetalNode {
    
    public func parseRenderPassAttachmentXML(nodes: Container, elem: XMLElement) {
        //TODO: texture & ref
        if let val = elem.attributes["level"] { self.level = Int(val)! }
        if let val = elem.attributes["slice"] { self.slice = Int(val)! }
        if let val = elem.attributes["depth-plane"] { self.depthPlane = Int(val)! }
        
        //TODO: resolveTexture & ref
        if let val = elem.attributes["resolve-level"] { self.resolveLevel = Int(val)! }
        if let val = elem.attributes["resolve-slice"] {self.resolveSlice = Int(val)! }
        if let val = elem.attributes["resolve-depth-plane"] { self.resolveDepthPlane = Int(val)! }
        
        if let val = elem.attributes["load-action"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlLoadAction")!
            let enumVal = mtlEnum.getValue(val)
            self.loadAction = MTLLoadAction(rawValue: enumVal)!
        }
        if let val = elem.attributes["store-action"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStoreAction")!
            let enumVal = mtlEnum.getValue(val)
            self.storeAction = MTLStoreAction(rawValue: enumVal)!
        }
    }
    
    public func generateRenderPassAttachment(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()
        let ninj = injector?(inj) ?? inj
        
        if let val = self.loadAction { desc.loadAction = val }
        if let val = self.storeAction { desc.storeAction = val }
        
        // TODO: texture: check options, then injector, then try to generate the texture node
        if let val = self.level { desc.level = val }
        if let val = self.slice { desc.slice = val }
        if let val = self.depthPlane { desc.depthPlane = val }
        
        // TODO: resolveTexture: check options, then injector, then try to generate the texture node
        if let val = self.resolveLevel { desc.resolveLevel = val }
        if let val = self.resolveSlice { desc.resolveSlice = val }
        if let val = self.resolveDepthPlane { desc.resolveDepthPlane = val }
        return desc
    }
    
    public func copyRenderPassAttachment() -> Self {
        var cp = Self()
        cp.texture = self.texture?.copy()
        cp.level = self.level
        cp.slice = self.slice
        cp.depthPlane = self.depthPlane
        cp.loadAction = self.loadAction
        cp.storeAction = self.storeAction
        cp.resolveTexture = self.resolveTexture?.copy()
        cp.resolveLevel = self.resolveLevel
        cp.resolveSlice = self.resolveSlice
        cp.resolveDepthPlane = self.resolveDepthPlane
        return cp
    }
}

public final class RenderPassColorAttachmentDescriptorNode: MetalNode, RenderPassAttachmentDescriptorNode {
    public typealias NodeType = RenderPassColorAttachmentDescriptorNode
    public typealias MTLType = MTLRenderPassColorAttachmentDescriptor

    public var id: String?
    public var clearColor: ClearColorNode?
    
    public var texture: TextureDescriptorNode?
    public var level: Int?
    public var slice: Int?
    public var depthPlane: Int?
    public var loadAction: MTLLoadAction?
    public var storeAction: MTLStoreAction?
    public var resolveTexture: TextureDescriptorNode?
    public var resolveLevel: Int?
    public var resolveSlice: Int?
    public var resolveDepthPlane: Int?
    
    public required init() {
        // required for copy
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }

        parseRenderPassAttachmentXML(nodes, elem: elem)

        if let clearColorTag = elem.firstChild(tag: "clear-color") {
            if let clearColorName = clearColorTag.attributes["ref"] {
                self.clearColor = nodes.resolve(ClearColorNode.self, name: clearColorName)!
            } else {
                let clearColor = ClearColorNode(nodes: nodes, elem: clearColorTag)
                self.clearColor = clearColor

                if let id = clearColorTag.attributes["id"] {
                    nodes.register(ClearColorNode.self, name: id) { _ in
                        return clearColor
                        }.inObjectScope(.None)
                }
            }
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = generateRenderPassAttachment(inj, injector: injector)
        if let clearColor = self.clearColor?.generate(inj, injector: injector) {
            desc.clearColor = clearColor
        }
        return desc
    }

    public func copy() -> NodeType {
        let cp = copyRenderPassAttachment()
        cp.clearColor = self.clearColor?.copy()
        return cp
    }
}


public final class RenderPassStencilAttachmentDescriptorNode: MetalNode, RenderPassAttachmentDescriptorNode {
    public typealias NodeType = RenderPassStencilAttachmentDescriptorNode
    public typealias MTLType = MTLRenderPassStencilAttachmentDescriptor
    
    public var id: String?
    public var clearStencil: UInt32?
    
    public var texture: TextureDescriptorNode?
    public var level: Int?
    public var slice: Int?
    public var depthPlane: Int?
    public var loadAction: MTLLoadAction?
    public var storeAction: MTLStoreAction?
    public var resolveTexture: TextureDescriptorNode?
    public var resolveLevel: Int?
    public var resolveSlice: Int?
    public var resolveDepthPlane: Int?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        
        parseRenderPassAttachmentXML(nodes, elem: elem)
        
        if let val = elem.attributes["clear-stencil"] {
            self.clearStencil = UInt32(val)!
        }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = generateRenderPassAttachment(inj, injector: injector)
        if let val = self.clearStencil { desc.clearStencil = val }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = copyRenderPassAttachment()
        cp.clearStencil = self.clearStencil
        return cp
    }
}

public final class RenderPassDepthAttachmentDescriptorNode: MetalNode, RenderPassAttachmentDescriptorNode {
    public typealias NodeType = RenderPassDepthAttachmentDescriptorNode
    public typealias MTLType = MTLRenderPassDepthAttachmentDescriptor
    
    public var id: String?
    public var clearDepth: Double?
    #if os(iOS)
    public var depthResolveFilter: MTLMultisampleDepthResolveFilter?
    #endif
    
    public var texture: TextureDescriptorNode?
    public var level: Int?
    public var slice: Int?
    public var depthPlane: Int?
    public var loadAction: MTLLoadAction?
    public var storeAction: MTLStoreAction?
    public var resolveTexture: TextureDescriptorNode?
    public var resolveLevel: Int?
    public var resolveSlice: Int?
    public var resolveDepthPlane: Int?
    
    public required init() {
        // required for copy
    }
    
    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }
    
    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }
        
        parseRenderPassAttachmentXML(nodes, elem: elem)
        
        if let val = elem.attributes["clear-depth"] { self.clearDepth = Double(val)! }
        
        #if os(iOS)
            if let val = elem.attributes["depth-resolve-filter"] {
                let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlMultisampleDepthResolveFilter")!
                let enumVal = mtlEnum.getValue(val)
                self.depthResolveFilter = MTLMultisampleDepthResolveFilter(rawValue: enumVal)!
            }
        #endif
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let ninj = injector?(inj) ?? inj
        let desc = generateRenderPassAttachment(inj, injector: injector)
        if let val = self.clearDepth { desc.clearDepth = val }
        
        #if os(iOS)
            if let val = self.depthResolveFilter { desc.depthResolveFilter = val }
        #endif
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = copyRenderPassAttachment()
        cp.clearDepth = self.clearDepth
        #if os(iOS)
            cp.depthResolveFilter = self.depthResolveFilter
        #endif
        return cp
    }
}

public class RenderPassDescriptorNode: MetalNode {
    // NOTE: this node has to handle transforming options to send to lower render pass attachment descriptors!!
    
    public typealias NodeType = RenderPassDescriptorNode
    public typealias MTLType = MTLRenderPassDescriptor

    public var id: String?
    
    public var colorAttachments: [RenderPassColorAttachmentDescriptorNode] = []
    public var depthAttachment: RenderPassDepthAttachmentDescriptorNode?
    public var stencilAttachment: RenderPassStencilAttachmentDescriptorNode?

    public required init() {
        
    }

    public required init(nodes: Container, elem: XMLElement) {
        parseXML(nodes, elem: elem)
    }

    public func parseXML(nodes: Container, elem: XMLElement) {
        if let val = elem.attributes["id"] { self.id = val }

        let attachSelector = "render-pass-color-attachment-descriptors > render-pass-color-attachment-descriptor"
        for (idx, el) in elem.css(attachSelector).enumerate() {
            if let colorAttachName = el.attributes["ref"] {
                self.colorAttachments[Int(idx)] = nodes.resolve(RenderPassColorAttachmentDescriptorNode.self, name: colorAttachName)!
            } else {
                let colorAttach = RenderPassColorAttachmentDescriptorNode(nodes: nodes, elem: el)
                self.colorAttachments[Int(idx)] = colorAttach

                if let id = el.attributes["id"] {
                    nodes.register(RenderPassColorAttachmentDescriptorNode.self, name: id) { _ in
                        return colorAttach
                        }.inObjectScope(.None)
                }
            }
        }

        if let depthAttachTag = elem.firstChild(tag: "render-pass-depth-attachment-descriptor") {
            if let depthAttachName = depthAttachTag.attributes["ref"] {
                self.depthAttachment = nodes.resolve(RenderPassDepthAttachmentDescriptorNode.self, name: depthAttachName)!
            } else {
                let depthAttach = RenderPassDepthAttachmentDescriptorNode(nodes: nodes, elem: depthAttachTag)
                self.depthAttachment = depthAttach

                if let id = depthAttachTag.attributes["id"] {
                    nodes.register(RenderPassDepthAttachmentDescriptorNode.self, name: id) { _ in
                        return depthAttach
                        }.inObjectScope(.None)
                }
            }
        }

        if let stencilAttachTag = elem.firstChild(tag: "render-pass-stencil-attachment-descriptor") {
            if let stencilAttachName = stencilAttachTag.attributes["ref"] {
                self.stencilAttachment = nodes.resolve(RenderPassStencilAttachmentDescriptorNode.self, name: stencilAttachName)!
            } else {
                let stencilAttach = RenderPassStencilAttachmentDescriptorNode(nodes: nodes, elem: stencilAttachTag)
                self.stencilAttachment = stencilAttach

                if let id = stencilAttachTag.attributes["id"] {
                    nodes.register(RenderPassStencilAttachmentDescriptorNode.self, name: id) { _ in
                        return stencilAttach
                        }.inObjectScope(.None)
                }
            }
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
        let desc = MTLType()

        return desc
    }

    public func copy() -> NodeType {
        let cp = NodeType()
        cp.colorAttachments = self.colorAttachments.map { $0.copy() }
        cp.depthAttachment = self.depthAttachment?.copy()
        cp.stencilAttachment = self.stencilAttachment?.copy()
        return cp
    }
}

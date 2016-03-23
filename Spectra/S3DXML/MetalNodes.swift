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
        let desc = MTLType()
        // TODO: reduce over attributes & layouts.  merge injected.options?
        for (idx, node) in self.attributes.enumerate() {
            //TODO: should injector be nil for nested objects? with option to read from inj.options?
            let attrDesc = node.generate(inj, injector: nil)
            desc.attributes[idx] = attrDesc
        }
        for (idx, node) in self.layouts.enumerate() {
            let layoutDesc = node.generate(inj, injector: nil)
            desc.layouts[idx] = layoutDesc
        }
        return desc
    }
    
    public func copy() -> NodeType {
        let cp = NodeType()
        cp.attributes = self.attributes.reduce([], combine: {$0 + [$1.copy()]})
        cp.layouts = self.layouts.reduce([], combine: {$0 + [$1.copy()]})
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
        if let stepRate = elem.attributes["step-rate"] {
            self.stepRate = Int(stepRate)!
        }
    }
    
    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
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
        if let val = elem.attributes["width"] {
            self.width = Int(val)!
        }
        if let val = elem.attributes["height"] {
            self.height = Int(val)!
        }
        if let val = elem.attributes["depth"] {
            self.depth = Int(val)!
        }
        if let val = elem.attributes["mipmap-level-count"] {
            self.mipmapLevelCount = Int(val)!
        }
        if let val = elem.attributes["sample-count"] {
            self.sampleCount = Int(val)!
        }
        if let val = elem.attributes["array-length"] {
            self.arrayLength = Int(val)!
        }
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
        if let label = elem.attributes["label"] {
            self.label = label
        }
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
        if let val = elem.attributes["max-anisotropy"] {
            self.maxAnisotropy = Int(val)!
        }
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
        if let val = elem.attributes["normalized-coordinates"] {
            self.normalizedCoordinates = (val == "true")
        }
        if let val = elem.attributes["lod-min-clamp"] {
            self.lodMinClamp = Float(val)!
        }
        if let val = elem.attributes["lod-max-clamp"] {
            self.lodMaxClamp = Float(val)!
        }
        if let val = elem.attributes["lod-average"] {
             self.lodAverage = true
        }
        if let val = elem.attributes["compare-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCompareFunction")!
            let enumVal = mtlEnum.getValue(val)
            self.compareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
    }

    public func generate(inj: SpectraInjected, injector: MetalNodeInjector?) -> MTLType {
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
        if let stencilCompare = elem.attributes["stencil-compare-function"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlCompareFunction")!
            let enumVal = mtlEnum.getValue(stencilCompare)
            self.stencilCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let stencilFailureOp = elem.attributes["stencil-failure-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(stencilFailureOp)
            self.stencilFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthFailureOp = elem.attributes["depth-failure-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(depthFailureOp)
            self.depthFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthStencilPassOp = elem.attributes["depth-stencil-pass-operation"] {
            let mtlEnum = nodes.resolve(MetalEnum.self, name: "mtlStencilOperation")!
            let enumVal = mtlEnum.getValue(depthStencilPassOp)
            self.depthStencilPassOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let readMask = elem.attributes["read-mask"] {
            self.readMask = UInt32(readMask)!
        }
        if let writeMask = elem.attributes["write-mask"] {
            self.writeMask = UInt32(writeMask)!
        }
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

//public class S3DXMLMTLDepthStencilDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLDepthStencilDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let depthDesc = NodeType()
//        
//        if let label = elem.attributes["label"] {
//            depthDesc.label = label
//        }
//        if let depthCompare = elem.attributes["depth-compare-function"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlCompareFunction")!
//            let enumVal = mtlEnum.getValue(depthCompare)
//            depthDesc.depthCompareFunction = MTLCompareFunction(rawValue: enumVal)!
//        }
//        if let _ = elem.attributes["depth-write-enabled"] {
//            depthDesc.depthWriteEnabled = true
//        }
//        
//        if let frontFaceTag = elem.firstChild(tag: "front-face-stencil") {
//            if let frontFaceName = frontFaceTag.attributes["ref"] {
//                depthDesc.frontFaceStencil = container.resolve(MTLStencilDescriptor.self, name: frontFaceName)!
//            } else {
//                let frontFaceStencil = S3DXMLMTLStencilDescriptorNode().parse(container, elem: frontFaceTag)
//                depthDesc.frontFaceStencil = frontFaceStencil
//                
//                // also, register the descriptor, if named (not thread friendly)
//                if let id = frontFaceTag.attributes["id"] {
//                    container.register(MTLStencilDescriptor.self, name: id) { _ in
//                        return frontFaceStencil.copy() as! MTLStencilDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let backFaceTag = elem.firstChild(tag: "back-face-stencil") {
//            if let backFaceName = backFaceTag.attributes["ref"] {
//                depthDesc.backFaceStencil = container.resolve(MTLStencilDescriptor.self, name: backFaceName)!
//            } else {
//                let backFaceStencil = S3DXMLMTLStencilDescriptorNode().parse(container, elem: backFaceTag)
//                depthDesc.backFaceStencil = backFaceStencil
//                
//                // also, register the descriptor, if named (not thread friendly)
//                if let id = backFaceTag.attributes["id"] {
//                    container.register(MTLStencilDescriptor.self, name: id) { _ in
//                        return backFaceStencil.copy() as! MTLStencilDescriptor
//                    }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        return depthDesc
//    }
//}
//
//public class S3DXMLMTLColorAttachmentDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPipelineColorAttachmentDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPipelineColorAttachmentDescriptor()
//        
//        if let pixelFormat = elem.attributes["pixel-format"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlPixelFormat")!
//            let enumVal = mtlEnum.getValue(pixelFormat)
//            desc.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
//        }
//        if let _ = elem.attributes["blending-enabled"] {
//            desc.blendingEnabled = true
//        }
//        if let sourceRgbBlendFactor = elem.attributes["source-rgb-blend-factor"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendFactor")!
//            let enumVal = mtlEnum.getValue(sourceRgbBlendFactor)
//            desc.sourceRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
//        }
//        if let destRgbBlendFactor = elem.attributes["destination-rgb-blend-factor"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendFactor")!
//            let enumVal = mtlEnum.getValue(destRgbBlendFactor)
//            desc.destinationRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
//        }
//        if let rgbBlendOp = elem.attributes["rgb-blend-operation"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendOperation")!
//            let enumVal = mtlEnum.getValue(rgbBlendOp)
//            desc.rgbBlendOperation = MTLBlendOperation(rawValue: enumVal)!
//        }
//        if let sourceAlphaBlendFactor = elem.attributes["source-alpha-blend-factor"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendFactor")!
//            let enumVal = mtlEnum.getValue(sourceAlphaBlendFactor)
//            desc.sourceAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
//        }
//        if let destAlphaBlendFactor = elem.attributes["destination-alpha-blend-factor"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendFactor")!
//            let enumVal = mtlEnum.getValue(destAlphaBlendFactor)
//            desc.destinationAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
//        }
//        if let alphaBlendOp = elem.attributes["alpha-blend-operation"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlBlendOperation")!
//            let enumVal = mtlEnum.getValue(alphaBlendOp)
//            desc.alphaBlendOperation = MTLBlendOperation(rawValue: enumVal)!
//        }
//        //TODO: writeMask
//        
//        return desc
//    }
//}
//
//public class S3DXMLMTLRenderPipelineDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPipelineDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPipelineDescriptor()
//        
//        if let vertexFunctionTag = elem.firstChild(tag: "vertex-function") {
//            if let vertexFunctionName = vertexFunctionTag.attributes["ref"] {
//                desc.vertexFunction = container.resolve(MTLFunction.self, name: vertexFunctionName)
//            } else {
//                //TODO: attribute tag for library
//                let lib = container.resolve(MTLLibrary.self, name: "default")!
//                let vertexFunction = S3DXMLMTLFunctionNode(library: lib).parse(container, elem: vertexFunctionTag)
//                desc.vertexFunction = vertexFunction
//                
//                if let id = vertexFunctionTag.attributes["id"] {
//                    container.register(MTLFunction.self, name: id) { _ in
//                        return vertexFunction
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let fragmentFunctionTag = elem.firstChild(tag: "fragment-function") {
//            if let fragmentFunctionName = fragmentFunctionTag.attributes["ref"] {
//                desc.fragmentFunction = container.resolve(MTLFunction.self, name: fragmentFunctionName)
//            } else {
//                //TODO: attribute tag for library
//                let lib = container.resolve(MTLLibrary.self, name: "default")!
//                let fragmentFunction = S3DXMLMTLFunctionNode(library: lib).parse(container, elem: fragmentFunctionTag)
//                desc.fragmentFunction = fragmentFunction
//                
//                if let id = fragmentFunctionTag.attributes["id"] {
//                    container.register(MTLFunction.self, name: fragmentFunctionTag.attributes["id"]!) { _ in
//                        return fragmentFunction
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let vertexDescTag = elem.firstChild(tag: "vertex-descriptor") {
//            if let vertexDescName = vertexDescTag.attributes["ref"] {
//                desc.vertexDescriptor = container.resolve(MTLVertexDescriptor.self, name: vertexDescName)
//            } else {
//                let vertexDesc = S3DXMLMTLVertexDescriptorNode().parse(container, elem: vertexDescTag)
//                desc.vertexDescriptor = vertexDesc
//                
//                if let id = vertexDescTag.attributes["id"] {
//                    container.register(MTLVertexDescriptor.self, name: id) { _ in
//                        return vertexDesc.copy() as! MTLVertexDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        let colorAttachSelector = "color-attachment-descriptors > color-attachment-descriptor"
//        for (idx, el) in elem.css(colorAttachSelector).enumerate() {
//            if let colorAttachName = el.attributes["ref"] {
//                desc.colorAttachments[Int(idx)] = container.resolve(MTLRenderPipelineColorAttachmentDescriptor.self, name: colorAttachName)
//            } else {
//                let colorAttachDesc = S3DXMLMTLColorAttachmentDescriptorNode().parse(container, elem: el)
//                desc.colorAttachments[Int(idx)] = colorAttachDesc
//                
//                if let id = el.attributes["id"] {
//                    container.register(MTLRenderPipelineColorAttachmentDescriptor.self, name: id) { _ in
//                        return colorAttachDesc.copy() as! MTLRenderPipelineColorAttachmentDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let label = elem.attributes["label"] {
//            desc.label = label
//        }
//        if let sampleCount = elem.attributes["sample-count"] {
//            desc.sampleCount = Int(sampleCount)!
//        }
//        if let _ = elem.attributes["alpha-to-coverage-enabled"] {
//            desc.alphaToCoverageEnabled = true
//        }
//        if let _ = elem.attributes["alpha-to-one-enabled"] {
//            desc.alphaToOneEnabled = true
//        }
//        if let _ = elem.attributes["rasterization-enabled"] {
//            desc.rasterizationEnabled = true
//        }
//        if let depthPixelFormat = elem.attributes["depth-attachment-pixel-format"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlPixelFormat")!
//            let enumVal = mtlEnum.getValue(depthPixelFormat)
//            desc.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
//        }
//        if let stencilPixelFormat = elem.attributes["stencil-attachment-pixel-format"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlPixelFormat")!
//            let enumVal = mtlEnum.getValue(stencilPixelFormat)
//            desc.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
//        }
//        
//        return desc
//    }
//}
//
//public class S3DXMLMTLComputePipelineDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLComputePipelineDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLComputePipelineDescriptor()
//        
//        if let computeFunctionTag = elem.firstChild(tag: "compute-function") {
//            if let computeFunctionName = computeFunctionTag.attributes["ref"] {
//                desc.computeFunction = container.resolve(MTLFunction.self, name: computeFunctionName)
//            } else {
//                //TODO: attribute tag for library
//                let lib = container.resolve(MTLLibrary.self, name: "default")!
//                let computeFunction = S3DXMLMTLFunctionNode(library: lib).parse(container, elem: computeFunctionTag)
//                desc.computeFunction = computeFunction
//                
//                if let id = computeFunctionTag.attributes["id"] {
//                    container.register(MTLFunction.self, name: id) { _ in
//                        return computeFunction
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        if let label = elem.attributes["label"] {
//            desc.label = label
//        }
//        if let _ = elem.attributes["thread-group-size-is-multiple-of-thread-execution-width"] {
//            desc.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
//        }
//        
//        return desc
//    }
//}
//
//public class S3DXMLMTLClearColorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLClearColor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        var clearColor = MTLClearColor()
//        
//        if let red = elem.attributes["clear-red"] {
//            clearColor.red = Double(red)!
//        }
//        if let green = elem.attributes["clear-green"] {
//            clearColor.green = Double(green)!
//        }
//        if let blue = elem.attributes["clear-blue"] {
//            clearColor.blue = Double(blue)!
//        }
//        if let alpha = elem.attributes["clear-alpha"] {
//            clearColor.alpha = Double(alpha)!
//        }
//        
//        return clearColor
//    }
//}
//
//public class S3DXMLMTLRenderPassColorAttachmentDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPassColorAttachmentDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPassColorAttachmentDescriptor()
//        
//        //TODO: texture & ref
//        
//        if let level = elem.attributes["level"] {
//            desc.level = Int(level)!
//        }
//        if let slice = elem.attributes["slice"] {
//            desc.slice = Int(slice)!
//        }
//        if let depthPlane = elem.attributes["depth-plane"] {
//            desc.depthPlane = Int(depthPlane)!
//        }
//        
//        //TODO: resolveTexture & ref
//        
//        if let resolveLevel = elem.attributes["resolve-level"] {
//            desc.resolveLevel = Int(resolveLevel)!
//        }
//        if let resolveSlice = elem.attributes["resolve-slice"] {
//            desc.resolveSlice = Int(resolveSlice)!
//        }
//        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
//            desc.resolveDepthPlane = Int(resolveDepthPlane)!
//        }
//        if let loadAction = elem.attributes["load-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlLoadAction")!
//            let enumVal = mtlEnum.getValue(loadAction)
//            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
//        }
//        if let storeAction = elem.attributes["store-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlStoreAction")!
//            let enumVal = mtlEnum.getValue(storeAction)
//            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
//        }
//        
//        if let clearColorTag = elem.firstChild(tag: "clear-color") {
//            if let clearColorName = clearColorTag.attributes["ref"] {
//                desc.clearColor = container.resolve(MTLClearColor.self, name: clearColorName)!
//            } else {
//                let clearColor = S3DXMLMTLClearColorNode().parse(container, elem: clearColorTag)
//                desc.clearColor = clearColor
//                
//                if let id = clearColorTag.attributes["id"] {
//                    container.register(MTLClearColor.self, name: id) { _ in
//                        return clearColor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        return desc
//    }
//}
//
//public class S3DXMLMTLRenderPassDepthAttachmentDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPassDepthAttachmentDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPassDepthAttachmentDescriptor()
//        
//        //TODO: texture & ref
//        
//        if let level = elem.attributes["level"] {
//            desc.level = Int(level)!
//        }
//        if let slice = elem.attributes["slice"] {
//            desc.slice = Int(slice)!
//        }
//        if let depthPlane = elem.attributes["depth-plane"] {
//            desc.depthPlane = Int(depthPlane)!
//        }
//        
//        //TODO: resolveTexture & ref
//        
//        if let resolveLevel = elem.attributes["resolve-level"] {
//            desc.resolveLevel = Int(resolveLevel)!
//        }
//        if let resolveSlice = elem.attributes["resolve-slice"] {
//            desc.resolveSlice = Int(resolveSlice)!
//        }
//        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
//            desc.resolveDepthPlane = Int(resolveDepthPlane)!
//        }
//        if let loadAction = elem.attributes["load-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlLoadAction")!
//            let enumVal = mtlEnum.getValue(loadAction)
//            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
//        }
//        if let storeAction = elem.attributes["store-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlStoreAction")!
//            let enumVal = mtlEnum.getValue(storeAction)
//            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
//        }
//        if let clearDepth = elem.attributes["clear-depth"] {
//            desc.clearDepth = Double(clearDepth)!
//        }
//        #if os(iOS)
//        if let depthResolveFilter = elem.attributes["depth-resolve-filter"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlMultisampleDepthResolveFilter")!
//            let enumVal = mtlEnum.getValue(depthResolveFilter)
//            desc.depthResolveFilter = MTLMultisampleDepthResolveFilter(rawValue: enumVal)!
//        }
//        #endif
//        return desc
//    }
//}
//
//public class S3DXMLMTLRenderPassStencilAttachmentDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPassStencilAttachmentDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPassStencilAttachmentDescriptor()
//        
//        //TODO: texture & ref
//        
//        if let level = elem.attributes["level"] {
//            desc.level = Int(level)!
//        }
//        if let slice = elem.attributes["slice"] {
//            desc.slice = Int(slice)!
//        }
//        if let depthPlane = elem.attributes["depth-plane"] {
//            desc.depthPlane = Int(depthPlane)!
//        }
//        
//        //TODO: resolveTexture & ref
//        
//        if let resolveLevel = elem.attributes["resolve-level"] {
//            desc.resolveLevel = Int(resolveLevel)!
//        }
//        if let resolveSlice = elem.attributes["resolve-slice"] {
//            desc.resolveSlice = Int(resolveSlice)!
//        }
//        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
//            desc.resolveDepthPlane = Int(resolveDepthPlane)!
//        }
//        if let loadAction = elem.attributes["load-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlLoadAction")!
//            let enumVal = mtlEnum.getValue(loadAction)
//            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
//        }
//        if let storeAction = elem.attributes["store-action"] {
//            let mtlEnum = container.resolve(MetalEnum.self, name: "mtlStoreAction")!
//            let enumVal = mtlEnum.getValue(storeAction)
//            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
//        }
//        if let clearStencil = elem.attributes["clear-stencil"] {
//            desc.clearStencil = UInt32(clearStencil)!
//        }
//        
//        return desc
//    }
//}
//
//public class S3DXMLMTLRenderPassDescriptorNode: S3DXMLNodeParser {
//    public typealias NodeType = MTLRenderPassDescriptor
//    
//    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> NodeType {
//        let desc = MTLRenderPassDescriptor()
//        
//        let attachSelector = "render-pass-color-attachment-descriptors > render-pass-color-attachment-descriptor"
//        for (idx, el) in elem.css(attachSelector).enumerate() {
//            if let colorAttachName = el.attributes["ref"] {
//                desc.colorAttachments[Int(idx)] = container.resolve(MTLRenderPassColorAttachmentDescriptor.self, name: colorAttachName)
//            } else {
//                let colorAttach = S3DXMLMTLRenderPassColorAttachmentDescriptorNode().parse(container, elem: el)
//                desc.colorAttachments[Int(idx)] = colorAttach
//                
//                if let id = el.attributes["id"] {
//                    container.register(MTLRenderPassColorAttachmentDescriptor.self, name: id) { _ in
//                        return colorAttach.copy() as! MTLRenderPassColorAttachmentDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let depthAttachTag = elem.firstChild(tag: "render-pass-depth-attachment-descriptor") {
//            if let depthAttachName = depthAttachTag.attributes["ref"] {
//                desc.depthAttachment = container.resolve(MTLRenderPassDepthAttachmentDescriptor.self, name: depthAttachName)
//            } else {
//                let depthAttach = S3DXMLMTLRenderPassDepthAttachmentDescriptorNode().parse(container, elem: depthAttachTag)
//                desc.depthAttachment = depthAttach
//                
//                if let id = depthAttachTag.attributes["id"] {
//                    container.register(MTLRenderPassDepthAttachmentDescriptor.self, name: id) { _ in
//                        return depthAttach.copy() as! MTLRenderPassDepthAttachmentDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        if let stencilAttachTag = elem.firstChild(tag: "render-pass-stencil-attachment-descriptor") {
//            if let stencilAttachName = stencilAttachTag.attributes["ref"] {
//                desc.stencilAttachment = container.resolve(MTLRenderPassStencilAttachmentDescriptor.self, name: stencilAttachName)
//            } else {
//                let stencilAttach = S3DXMLMTLRenderPassStencilAttachmentDescriptorNode().parse(container, elem: stencilAttachTag)
//                desc.stencilAttachment = stencilAttach
//                
//                if let id = stencilAttachTag.attributes["id"] {
//                    container.register(MTLRenderPassStencilAttachmentDescriptor.self, name: id) { _ in
//                        return stencilAttach.copy() as! MTLRenderPassStencilAttachmentDescriptor
//                        }.inObjectScope(.Container)
//                }
//            }
//        }
//        
//        return desc
//    }
//}
//

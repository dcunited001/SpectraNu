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

public class S3DXML {
    public var xml: XMLDocument?
    
    public init(data: NSData) {
        do {
            xml = try XMLDocument(data: data)
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
    
    public func parse(library: MTLLibrary, container: Container) -> Container {
        for child in xml!.root!.children {
            let tag = child.tag!
            let key = child.attributes["key"]
            
            switch tag {
            case "vertex-function", "fragment-function", "compute-function":
                container.register(MTLFunction.self, name: key!) { r in
                    return S3DXMLMTLFunctionNode(library: library).parse(r as! Container, elem: child)
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
                    
                }.inObjectScope(.Container)
            case "sampler-descriptor":
                container.register(MTLSamplerDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "stencil-descriptor":
                container.register(MTLStencilDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "depth-stencil-descriptor":
                container.register(MTLDepthStencilDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pipeline-color-attachment-descriptor":
                container.register(MTLRenderPipelineColorAttachmentDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "compute-pipeline-descriptor":
                container.register(MTLComputePipelineDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pipeline-descriptor":
                container.register(MTLRenderPipelineDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pass-color-attachment-descriptor":
                container.register(MTLRenderPassColorAttachmentDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pass-depth-attachment-descriptor":
                container.register(MTLRenderPassDepthAttachmentDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pass-stencil-attachment-descriptor":
                container.register(MTLRenderPassStencilAttachmentDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            case "render-pass-descriptor":
                container.register(MTLRenderPassDescriptor.self, name: key!) { r in
                    
                }.inObjectScope(.Container)
            default:
                break
            }
        }
        
        return container
    }
    
//    public func parseXML(bundle:NSBundle, filename: String) {
//        let xmlData = S3DXML.readXML(bundle, filename: "TestXML")
//        xml.parse(self)
    //    }
    
    public class func readXML(bundle: NSBundle, filename: String, bundleResourceName: String? = nil) -> NSData {
        
        var resourceBundle: NSBundle = bundle
        if let resourceName = bundleResourceName {
            let bundleURL = bundle.URLForResource(resourceName, withExtension: "bundle")
            resourceBundle = NSBundle(URL: bundleURL!)!
        }
        
        let path = resourceBundle.pathForResource(filename, ofType: "xml")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
}

//TODO: update valueForAttribute calls with guard statements and better error handling

public class S3DXMLMTLFunctionNode {
    var library: MTLLibrary!
    
    public init(library: MTLLibrary) {
        self.library = library
    }
    
    public func parse(container: Container, elem: XMLElement, options: [String: AnyObject] = [:]) -> MTLFunction {
        let name = elem.attributes["key"]
        let mtlFunction = library.newFunctionWithName(name!)
        return mtlFunction!
    }
}

public class S3DXMLMTLVertexDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String: AnyObject] = [:]) -> MTLVertexDescriptor {
        let vertexDesc = MTLVertexDescriptor()
        
        let attributeDescSelector = "vertex-attribute-descriptors > vertex-attribute-descriptor"
        for (idx, child) in elem.css(attributeDescSelector).enumerate() {
            let node = S3DXMLMTLVertexAttributeDescriptorNode()
            vertexDesc.attributes[idx] = node.parse(descriptorManager, elem: child)
        }
        
        let bufferLayoutDescSelector = "vertex-buffer-layout-descriptors > vertex-buffer-layout-descriptor"
        for (idx, child) in elem.css(bufferLayoutDescSelector).enumerate() {
            let node = S3DXMLMTLVertexBufferLayoutDescriptorNode()
            vertexDesc.layouts[idx] = node.parse(descriptorManager, elem: child)
        }
        
        return vertexDesc
    }
}

public class S3DXMLMTLVertexAttributeDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLVertexAttributeDescriptor {
        let vertexAttrDesc = MTLVertexAttributeDescriptor()
        
        if let format = elem.attributes["format"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlVertexFormat"]!
            let enumVal = UInt(mtlEnum.getValue(format))
            vertexAttrDesc.format = MTLVertexFormat(rawValue: enumVal)!
        }
        if let offset = elem.attributes["offset"] {
            vertexAttrDesc.offset = Int(offset)!
        }
        if let bufferIndex = elem.attributes["bufferIndex"] {
            vertexAttrDesc.bufferIndex = Int(bufferIndex)!
        }
        
        return vertexAttrDesc
    }
}

public class S3DXMLMTLVertexBufferLayoutDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLVertexBufferLayoutDescriptor {
        let bufferLayoutDesc = MTLVertexBufferLayoutDescriptor()
        
        let stride = elem.attributes["stride"]!
        bufferLayoutDesc.stride = Int(stride)!
        
        if let stepFunction = elem.attributes["step-function"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlVertexStepFunction"]!
            let enumVal = UInt(mtlEnum.getValue(stepFunction))
            bufferLayoutDesc.stepFunction = MTLVertexStepFunction(rawValue: enumVal)!
        }
        if let stepRate = elem.attributes["step-rate"] {
            bufferLayoutDesc.stepRate = Int(stepRate)!
        }
        
        return bufferLayoutDesc
    }
}

public class S3DXMLMTLTextureDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLTextureDescriptor {
        
        let texDesc = MTLTextureDescriptor()
        if let textureType = elem.attributes["texture-type"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlTextureType"]!
            let enumVal = UInt(mtlEnum.getValue(textureType))
            texDesc.textureType = MTLTextureType(rawValue: enumVal)!
        }
        if let pixelFormat = elem.attributes["pixel-format"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(pixelFormat))
            texDesc.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let width = elem.attributes["width"] {
            texDesc.width = Int(width)!
        }
        if let height = elem.attributes["height"] {
            texDesc.height = Int(height)!
        }
        if let depth = elem.attributes["depth"] {
            texDesc.depth = Int(depth)!
        }
        if let mipmapLevelCount = elem.attributes["mipmap-level-count"] {
            texDesc.mipmapLevelCount = Int(mipmapLevelCount)!
        }
        if let sampleCount = elem.attributes["sample-count"] {
            texDesc.sampleCount = Int(sampleCount)!
        }
        if let arrayLength = elem.attributes["array-length"] {
            texDesc.arrayLength = Int(arrayLength)!
        }
        //TODO: resourceOptions is option set type
        // texDesc.resourceOptions?  optional?  set later?
        if let cpuCacheMode = elem.attributes["cpu-cache-mode"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlCpuCacheMode"]!
            let enumVal = UInt(mtlEnum.getValue(cpuCacheMode))
            texDesc.cpuCacheMode = MTLCPUCacheMode(rawValue: enumVal)!
        }
        if let storageMode = elem.attributes["storage-mode"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStorageMode"]!
            let enumVal = UInt(mtlEnum.getValue(storageMode))
            texDesc.storageMode = MTLStorageMode(rawValue: enumVal)!
        }
//        if let usage = elem.valueForAttribute("usage") as? String {
//            //TODO: option set type
//            let mtlEnum = descriptorManager.mtlEnums["mtlTextureUsage"]!
//            let enumVal = UInt(mtlEnum.getValue(usage))
//            print(MTLTextureUsage.PixelFormatView)
//            texDesc.usage = MTLTextureUsage(rawValue: enumVal)
//        }
        
        return texDesc
    }
}

public class S3DXMLMTLSamplerDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLSamplerDescriptor {
        let samplerDesc = MTLSamplerDescriptor()
        
        if let label = elem.attributes["label"] {
            samplerDesc.label = label
        }
        if let minFilter = elem.attributes["min-filter"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMinMagFilter"]!
            let enumVal = UInt(mtlEnum.getValue(minFilter))
            samplerDesc.minFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let magFilter = elem.attributes["mag-filter"]{
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMinMagFilter"]!
            let enumVal = UInt(mtlEnum.getValue(magFilter))
            samplerDesc.magFilter = MTLSamplerMinMagFilter(rawValue: enumVal)!
        }
        if let mipFilter = elem.attributes["mip-filter"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerMipFilter"]!
            let enumVal = UInt(mtlEnum.getValue(mipFilter))
            samplerDesc.mipFilter = MTLSamplerMipFilter(rawValue: enumVal)!
        }
        if let maxAnisotropy = elem.attributes["max-anisotropy"] {
            samplerDesc.maxAnisotropy = Int(maxAnisotropy)!
        }
        if let sAddress = elem.attributes["s-address-mode"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(sAddress))
            samplerDesc.sAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let rAddress = elem.attributes["r-address-mode"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(rAddress))
            samplerDesc.rAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let tAddress = elem.attributes["t-address-mode"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlSamplerAddressMode"]!
            let enumVal = UInt(mtlEnum.getValue(tAddress))
            samplerDesc.tAddressMode = MTLSamplerAddressMode(rawValue: enumVal)!
        }
        if let normCoord = elem.attributes["normalized-coordinates"] {
            samplerDesc.normalizedCoordinates = (normCoord == "true")
        }
        if let lodMinClamp = elem.attributes["lod-min-clamp"] {
            samplerDesc.lodMinClamp = Float(lodMinClamp)!
        }
        if let lodMaxClamp = elem.attributes["lod-max-clamp"] {
            samplerDesc.lodMaxClamp = Float(lodMaxClamp)!
        }
        #if os(iOS)
        if let _ = elem.attributes["lod-average"] {
             samplerDesc.lodAverage = true
        }
        #endif
        if let compareFn = elem.attributes["compare-function"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareFunction"]!
            let enumVal = UInt(mtlEnum.getValue(compareFn))
            samplerDesc.compareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        
        return samplerDesc
    }
}

public class S3DXMLMTLStencilDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLStencilDescriptor {
        let stencilDesc = MTLStencilDescriptor()
        
        if let stencilCompare = elem.attributes["stencil-compare-function"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareFunction"]!
            let enumVal = UInt(mtlEnum.getValue(stencilCompare))
            stencilDesc.stencilCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let stencilFailureOp = elem.attributes["stencil-failure-operation"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(stencilFailureOp))
            stencilDesc.stencilFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthFailureOp = elem.attributes["depth-failure-operation"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(depthFailureOp))
            stencilDesc.depthFailureOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let depthStencilPassOp = elem.attributes["depth-stencil-pass-operation"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStencilOperation"]!
            let enumVal = UInt(mtlEnum.getValue(depthStencilPassOp))
            stencilDesc.depthStencilPassOperation = MTLStencilOperation(rawValue: enumVal)!
        }
        if let readMask = elem.attributes["read-mask"] {
            stencilDesc.readMask = UInt32(readMask)!
        }
        if let writeMask = elem.attributes["write-mask"] {
            stencilDesc.writeMask = UInt32(writeMask)!
        }
        
        return stencilDesc
    }
}

public class S3DXMLMTLDepthStencilDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLDepthStencilDescriptor {
        let depthDesc = NodeType()
        
        if let label = elem.attributes["label"] {
            depthDesc.label = label
        }
        if let depthCompare = elem.attributes["depth-compare-function"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlCompareFunction"]!
            let enumVal = UInt(mtlEnum.getValue(depthCompare))
            depthDesc.depthCompareFunction = MTLCompareFunction(rawValue: enumVal)!
        }
        if let _ = elem.attributes["depth-write-enabled"] {
            depthDesc.depthWriteEnabled = true
        }
        
        if let frontFaceTag = elem.firstChild(tag: "front-face-stencil") {
            if let frontFaceName = frontFaceTag.attributes["ref"] {
                depthDesc.frontFaceStencil = descriptorManager.stencilDescriptors[frontFaceName]!
            } else {
                let node = S3DXMLMTLStencilDescriptorNode()
                depthDesc.frontFaceStencil = node.parse(descriptorManager, elem: frontFaceTag)
            }
        }
        
        if let backFaceTag = elem.firstChild(tag: "back-face-stencil") {
            if let backFaceName = backFaceTag.attributes["ref"] {
                depthDesc.backFaceStencil = descriptorManager.stencilDescriptors[backFaceName]!
            } else {
                let node = S3DXMLMTLStencilDescriptorNode()
                depthDesc.backFaceStencil = node.parse(descriptorManager, elem: backFaceTag)
            }
        }
        
        return depthDesc
    }
}

public class S3DXMLMTLColorAttachmentDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPipelineColorAttachmentDescriptor {
        let desc = MTLRenderPipelineColorAttachmentDescriptor()
        
        if let pixelFormat = elem.attributes["pixel-format"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(pixelFormat))
            desc.pixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let _ = elem.attributes["blending-enabled"] {
            desc.blendingEnabled = true
        }
        if let sourceRgbBlendFactor = elem.attributes["source-rgb-blend-factor"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(sourceRgbBlendFactor))
            desc.sourceRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let destRgbBlendFactor = elem.attributes["destination-rgb-blend-factor"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(destRgbBlendFactor))
            desc.destinationRGBBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let rgbBlendOp = elem.attributes["rgb-blend-operation"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendOperation"]!
            let enumVal = UInt(mtlEnum.getValue(rgbBlendOp))
            desc.rgbBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
        if let sourceAlphaBlendFactor = elem.attributes["source-alpha-blend-factor"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(sourceAlphaBlendFactor))
            desc.sourceAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let destAlphaBlendFactor = elem.attributes["destination-alpha-blend-factor"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendFactor"]!
            let enumVal = UInt(mtlEnum.getValue(destAlphaBlendFactor))
            desc.destinationAlphaBlendFactor = MTLBlendFactor(rawValue: enumVal)!
        }
        if let alphaBlendOp = elem.attributes["alpha-blend-operation"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlBlendOperation"]!
            let enumVal = UInt(mtlEnum.getValue(alphaBlendOp))
            desc.alphaBlendOperation = MTLBlendOperation(rawValue: enumVal)!
        }
        //TODO: writeMask
        
        return desc
    }
}

public class S3DXMLMTLRenderPipelineDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPipelineDescriptor {
        let desc = MTLRenderPipelineDescriptor()
        
        if let vertexFunctionTag = elem.firstChild(tag: "vertex-function") {
            if let vertexFunctionName = vertexFunctionTag.attributes["ref"] {
                desc.vertexFunction = descriptorManager.vertexFunctions[vertexFunctionName]!
            }
        }
        
        if let fragmentFunctionTag = elem.firstChild(tag: "fragment-function") {
            if let fragmentFunctionName = fragmentFunctionTag.attributes["ref"] {
                desc.fragmentFunction = descriptorManager.fragmentFunctions[fragmentFunctionName]!
            }
        }
        
        if let vertexDescTag = elem.firstChild(tag: "vertex-descriptor") {
            if let vertexDescName = vertexDescTag.attributes["ref"] {
                print(descriptorManager.vertexDescriptors)
                desc.vertexDescriptor = descriptorManager.vertexDescriptors[vertexDescName]!
            }
        }
        
        let colorAttachSelector = "color-attachment-descriptors > color-attachment-descriptor"
        for (idx, el) in elem.css(colorAttachSelector).enumerate() {
            if let colorAttachRef = el.attributes["ref"] {
                let colorAttach = descriptorManager.colorAttachmentDescriptors[colorAttachRef]!
                desc.colorAttachments[Int(idx)] = colorAttach
            } else {
                let node = S3DXMLMTLColorAttachmentDescriptorNode()
                desc.colorAttachments[Int(idx)] = node.parse(descriptorManager, elem: elem)
            }
        }
        
        if let label = elem.attributes["label"] {
            desc.label = label
        }
        if let sampleCount = elem.attributes["sample-count"] {
            desc.sampleCount = Int(sampleCount)!
        }
        if let _ = elem.attributes["alpha-to-coverage-enabled"] {
            desc.alphaToCoverageEnabled = true
        }
        if let _ = elem.attributes["alpha-to-one-enabled"] {
            desc.alphaToOneEnabled = true
        }
        if let _ = elem.attributes["rasterization-enabled"] {
            desc.rasterizationEnabled = true
        }
        if let depthPixelFormat = elem.attributes["depth-attachment-pixel-format"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(depthPixelFormat))
            desc.depthAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        if let stencilPixelFormat = elem.attributes["stencil-attachment-pixel-format"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlPixelFormat"]!
            let enumVal = UInt(mtlEnum.getValue(stencilPixelFormat))
            desc.stencilAttachmentPixelFormat = MTLPixelFormat(rawValue: enumVal)!
        }
        
        return desc
    }
}

public class S3DXMLMTLComputePipelineDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLComputePipelineDescriptor {
        let desc = MTLComputePipelineDescriptor()
        
        if let computeFunctionTag = elem.firstChild(tag: "compute-function") {
            if let computeFunctionName = computeFunctionTag.attributes["ref"] {
                desc.computeFunction = descriptorManager.computeFunctions[computeFunctionName]!
            }
        }
        if let label = elem.attributes["label"] {
            desc.label = label
        }
        if let _ = elem.attributes["thread-group-size-is-multiple-of-thread-execution-width"] {
            desc.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        }
        
        return desc
    }
}

public class S3DXMLMTLRenderPassColorAttachmentDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPassColorAttachmentDescriptor {
        let desc = MTLRenderPassColorAttachmentDescriptor()
        
        //TODO: texture & ref
        
        if let level = elem.attributes["level"] {
            desc.level = Int(level)!
        }
        if let slice = elem.attributes["slice"] {
            desc.slice = Int(slice)!
        }
        if let depthPlane = elem.attributes["depth-plane"] {
            desc.depthPlane = Int(depthPlane)!
        }
        
        //TODO: resolveTexture & ref
        
        if let resolveLevel = elem.attributes["resolve-level"] {
            desc.resolveLevel = Int(resolveLevel)!
        }
        if let resolveSlice = elem.attributes["resolve-slice"] {
            desc.resolveSlice = Int(resolveSlice)!
        }
        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
            desc.resolveDepthPlane = Int(resolveDepthPlane)!
        }
        if let loadAction = elem.attributes["load-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlLoadAction"]!
            let enumVal = UInt(mtlEnum.getValue(loadAction))
            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
        }
        if let storeAction = elem.attributes["store-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStoreAction"]!
            let enumVal = UInt(mtlEnum.getValue(storeAction))
            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
        }
        
        //TODO: clearColor: MTLClearColor // default: rgba(0,0,0,1)
        
        return desc
    }
}

public class S3DXMLMTLRenderPassDepthAttachmentDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPassDepthAttachmentDescriptor {
        let desc = MTLRenderPassDepthAttachmentDescriptor()
        
        //TODO: texture & ref
        
        if let level = elem.attributes["level"] {
            desc.level = Int(level)!
        }
        if let slice = elem.attributes["slice"] {
            desc.slice = Int(slice)!
        }
        if let depthPlane = elem.attributes["depth-plane"] {
            desc.depthPlane = Int(depthPlane)!
        }
        
        //TODO: resolveTexture & ref
        
        if let resolveLevel = elem.attributes["resolve-level"] {
            desc.resolveLevel = Int(resolveLevel)!
        }
        if let resolveSlice = elem.attributes["resolve-slice"] {
            desc.resolveSlice = Int(resolveSlice)!
        }
        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
            desc.resolveDepthPlane = Int(resolveDepthPlane)!
        }
        if let loadAction = elem.attributes["load-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlLoadAction"]!
            let enumVal = UInt(mtlEnum.getValue(loadAction))
            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
        }
        if let storeAction = elem.attributes["store-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStoreAction"]!
            let enumVal = UInt(mtlEnum.getValue(storeAction))
            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
        }
        if let clearDepth = elem.attributes["clear-depth"] {
            desc.clearDepth = Double(clearDepth)!
        }
        if let depthResolveFilter = elem.attributes["depth-resolve-filter"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlMultisampleDepthResolveFilter"]!
            _ = UInt(mtlEnum.getValue(depthResolveFilter))
            
            //TODO: unavailable in OSX?
            //desc.depthResolveFilter = MTLMultisampleDepthResolveFilter(rawValue: enumVal)!
        }
        
        return desc
    }
}

public class S3DXMLMTLRenderPassStencilAttachmentDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPassStencilAttachmentDescriptor {
        let desc = MTLRenderPassStencilAttachmentDescriptor()
        
        //TODO: texture & ref
        
        if let level = elem.attributes["level"] {
            desc.level = Int(level)!
        }
        if let slice = elem.attributes["slice"] {
            desc.slice = Int(slice)!
        }
        if let depthPlane = elem.attributes["depth-plane"] {
            desc.depthPlane = Int(depthPlane)!
        }
        
        //TODO: resolveTexture & ref
        
        if let resolveLevel = elem.attributes["resolve-level"] {
            desc.resolveLevel = Int(resolveLevel)!
        }
        if let resolveSlice = elem.attributes["resolve-slice"] {
            desc.resolveSlice = Int(resolveSlice)!
        }
        if let resolveDepthPlane = elem.attributes["resolve-depth-plane"] {
            desc.resolveDepthPlane = Int(resolveDepthPlane)!
        }
        if let loadAction = elem.attributes["load-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlLoadAction"]!
            let enumVal = UInt(mtlEnum.getValue(loadAction))
            desc.loadAction = MTLLoadAction(rawValue: enumVal)!
        }
        if let storeAction = elem.attributes["store-action"] {
            let mtlEnum = descriptorManager.mtlEnums["mtlStoreAction"]!
            let enumVal = UInt(mtlEnum.getValue(storeAction))
            desc.storeAction = MTLStoreAction(rawValue: enumVal)!
        }
        if let clearStencil = elem.attributes["clear-stencil"] {
            desc.clearStencil = UInt32(clearStencil)!
        }
        
        return desc
    }
}

public class S3DXMLMTLRenderPassDescriptorNode {
    public func parse(container: Container, elem: XMLElement, options: [String : AnyObject] = [:]) -> MTLRenderPassDescriptor {
        let desc = MTLRenderPassDescriptor()
        
        let attachSelector = "render-pass-color-attachment-descriptors > render-pass-color-attachment-descriptor"
        for (idx, el) in elem.css(attachSelector).enumerate() {
            if let colorAttachRef = el.attributes["ref"] {
                let colorAttach = descriptorManager.renderPassColorAttachmentDescriptors[colorAttachRef]!
                desc.colorAttachments[Int(idx)] = colorAttach
            } else {
                let node = S3DXMLMTLRenderPassColorAttachmentDescriptorNode()
                desc.colorAttachments[Int(idx)] = node.parse(descriptorManager, elem: elem)
            }
        }
        
        if let depthAttachTag = elem.firstChild(tag: "render-pass-depth-attachment-descriptor") {
            if let depthAttachName = depthAttachTag.attributes["ref"] {
                desc.depthAttachment = descriptorManager.renderPassDepthAttachmentDescriptors[depthAttachName]!
            } else {
                let node = S3DXMLMTLRenderPassDepthAttachmentDescriptorNode()
                desc.depthAttachment = node.parse(descriptorManager, elem: depthAttachTag)
            }
        }
        
        if let stencilAttachTag = elem.firstChild(tag: "render-pass-stencil-attachment-descriptor") {
            if let stencilAttachName = stencilAttachTag.attributes["ref"] {
                desc.stencilAttachment = descriptorManager.renderPassStencilAttachmentDescriptors[stencilAttachName]!
            } else {
                let node = S3DXMLMTLRenderPassStencilAttachmentDescriptorNode()
                desc.stencilAttachment = node.parse(descriptorManager, elem: stencilAttachTag)
            }
        }
        
        return desc
    }
}


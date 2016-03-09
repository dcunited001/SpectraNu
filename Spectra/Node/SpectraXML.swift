//
//  SpectraXML.swift
//
//
//  Created by David Conner on 2/22/16.
//
//

import Foundation
import Fuzi
import Swinject
import MetalKit
import ModelIO

// PLZ NOTE: i promise I'm not pursuing this terrible XML parsing design for
//   lack of an alternative design.  Here's at least 3 issues I'm balancing:
// (1) minimize stored references to unnecessary data
//   - e.g. don't store XMLElement objects or accidentally retain stuff with closure definitions
// (2) avoid extending ModelIO & Metal base class (to add copy(), parseXML() and whatnot)
// (3) and avoid mirroring the ModelIO & Metal object's api's - which already mirror each other to some degree!
//   - simply mirroring the ModelIO & Metal api's by introducing new classes
//     where everything is mostly named the same just adds confusion
//   - although it makes it easier to add parseJSON(), parsePlist() & copy()
//
// that said, i'm sticking to this shit design because it's all probably going to change completely anyways,
//   so why fret over minor changes when a major change would make them all irrelevant?
//
// I do wish I knew of a meta way to do this:
// - something like Ruby's obj.responds_to(:"foo=") && obj.send(":foo", "bar")

public typealias SpectraXMLNodeParser = ((container: Container, node: XMLElement, key: String?, options: [String: Any]) -> AnyObject)

public enum SpectraXMLNodeType: String {
    case World = "world"
    case Camera = "camera"
    case Transform = "transform"
    case Asset = "asset"
    case BufferAllocator = "buffer-allocator"
    case Object = "object"
    case Mesh = "mesh"
    case MeshGenerator = "mesh-generator"
    case PhysicalLens = "physical-lens"
    case PhysicalImagingSurface = "physical-imaging-surface"
    case StereoscopicCamera = "stereoscopic-camera"
    case VertexAttribute = "vertex-attribute"
    case VertexDescriptor = "vertex-descriptor"
    case Material = "material"
    case MaterialProperty = "material-property"
    case ScatteringFunction = "scattering-function"
    case Texture = "texture"
    case TextureGenerator = "texture-generator"
    case TextureFilter = "texture-filter"
    case TextureSampler = "texture-sampler"
    case Light = "light"
    case LightGenerator = "light-generator"
    
    // TODO: reimplement nodeParser() once auto-injection is available in Swinject
    // - until then, I really can't resolve the type
    public func nodeParser(node: XMLElement, key: String, options: [String: Any] = [:]) -> SpectraXMLNodeParser? {
        
        //NOTE: nodeParser can't be used until either
        // - (1) Swinject supports auto-injection
        // - (2) I can resolve the reflection issues with resolving a swinject container of arbitrary type
        //    - can i do this with func generics: func nodeParser<NodeType>(...) -> SpectraXMLNodeParser<NodeType>?
        
        switch self {
        case .VertexAttribute: return {(container, node, key, options) in
            let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: node, options: options)
            return vertexAttr
            }
        case .VertexDescriptor:
            return {(container, node, key, options) in
                let vertexDesc = SpectraXMLVertexDescriptorNode().parse(container, elem: node, options: options)
                return vertexDesc
            }
        case .World:
            return {(container, node, key, options) in
                return "a world"
            }
        case .Camera:
            return {(container, node, key, options) in
                let cam = SpectraXMLCameraNode().parse(container, elem: node, options: options)
                return cam
            }
        case .MeshGenerator:
            return {(container, node, key, options) in
                return "a mesh generator"
            }
            
        default: return nil
        }
    }
    
    public func nodeFinalType(parser: Container) -> AnyClass? {
        switch self {
        case .VertexAttribute: return MDLVertexAttribute.self
        case .VertexDescriptor: return MDLVertexDescriptor.self
        default: return nil // custom types must be resolved separately
        }
    }
}

public class SpectraXML {
    var xml: XMLDocument?
    var parser: Container
    
    public init(parser: Container, data: NSData) {
        // NOTE: both this parser and the container injected into the SpectraXMLNodeParser functions
        // - should be able to reference the enum types read from the XSD file
        // - the simplest way to do this is create a container, load the XSD enums onto it,
        //   - then use this parser container as a parent: nodeParserContainer = Container(parent: parser)
        //   - refer to SpectraXMLSpec for an example
        // - or, if scoping is an issue, apply the enums to both the parser & nodeParser containers
        self.parser = parser
        
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
    
    public class func initParser(parser: Container) -> Container {
        //TODO: how to ensure that typing is consistent?
        // return [fnParse -> Any, fnCast -> MDLType] // this may work
        
        // yes, the design's a bit convoluted, but allows great flexibility!
        // - note: with great flexibility, comes great responsibility!!
        //   - this is true, both from a performance aspect (reference retention)
        // - as well as from a security aspect (arbitrary execution from remote XML)
        //   - spectra is intended as a LEARNING TOOL ONLY at this point.
        
        // NOTE: you can override default behavior by returning an alternative closure
        // - just do parser.register() and override.
        // - you can also do newParser = Container(parent: parser)
        //   - and then create a tree of custom parsers (see Swinject docs)
        
        // NOTE: if you do override default behavior for nodes: beware scoping
        // - if you pass node into the closure that's returned, it will stick around
        //   - instead just use node to determine which closure to return
        //   - that closure will get the node anyways
        // - same thing with options: beware retaining a reference
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexAttribute.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
            return SpectraXMLNodeType.VertexAttribute.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexDescriptor.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.VertexDescriptor.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.Camera.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.Camera.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.StereoscopicCamera.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.StereoscopicCamera.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.PhysicalLens.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.PhysicalLens.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.PhysicalImagingSurface.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.PhysicalImagingSurface.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        //        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.World.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
        //            return SpectraXMLNodeType.World.nodeParser(node, key: k, options: options)!
        //            }.inObjectScope(.None) // always return a new instance of the closure
        
        return parser
    }
    
    public func parse(container: Container, options: [String: Any] = [:]) {
        for child in xml!.root!.children {
            let (tag, key) = (child.tag!, child.attributes["key"])
            
            if let nodeType = SpectraXMLNodeType(rawValue: tag) {
                // let nodeParser = self.parser.resolve(SpectraXMLNodeParser.self, arguments: (tag, key, child, options))!
                // let nodeKlass = nodeType.nodeFinalType(parser)!.dynamicType
                // let result = nodeParser(container: container, node: child, key: key, options: options)
                
                // let resultKlass = SpectraXMLNodeType(rawValue: tag)!.nodeFinalType(parser)!
                // container.register(result.dynamicType, name: tag) { _ in
                //      return result
                //  }
                
                // TODO: move this out of parse() - it was in SpectraXMLNodeType,
                // - but i can't return an AnyClass and then parse it later
                switch nodeType {
                case .VertexAttribute:
                    let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: child, options: options)
                    container.register(MDLVertexAttribute.self, name: key!) { _ in
                        return (vertexAttr.copy() as! MDLVertexAttribute)
                        }.inObjectScope(.None)
                case .VertexDescriptor:
                    let vertexDesc = SpectraXMLVertexDescriptorNode().parse(container, elem: child, options: options)
                    container.register(MDLVertexDescriptor.self, name: key!)  { _ in
                        return MDLVertexDescriptor(vertexDescriptor: vertexDesc)
                        }.inObjectScope(.None)
                case .BufferAllocator:
                    let allocator = SpectraXMLBufferAllocatorNode().parse(container, elem: child, options: options)
                    container.register(MDLMeshBufferAllocator.self, name: key!) { _ in
                        return allocator
                        }.inObjectScope(.None)
                case .Asset:
                    let assetNode = AssetNode()
                    assetNode.parseXML(container, elem: child, options: options)
                    let asset = assetNode.generate(container)
                    container.register(MDLAsset.self, name: key!) { _ in
                        return asset.copy() as! MDLAsset
                        }.inObjectScope(.None)
                case .Object:
                    let obj = SpectraXMLObjectNode().parse(container, elem: child, options: options)
                    container.register(MDLObject.self, name: key!) { _ in
                        return SpectraXMLObjectNode.copy(obj)
                        }.inObjectScope(.None)
                case .Mesh:
                    let meshNode = MeshNode()
                    meshNode.parseXML(container, elem: child, options: options)
                    let meshGen = container.resolve(MeshGenerator.self, name: meshNode.generator)!
                    let mesh = meshGen.generate(container, args: meshNode.args)
                    container.register(MDLMesh.self, name: key!) { _ in
                        // TODO: don't copy meshes?
                        return mesh
                        }.inObjectScope(.None)
                case .MeshGenerator:
                    let meshGenNode = MeshGeneratorNode()
                    meshGenNode.parseXML(container, elem: child, options: options)
                    let meshGen = meshGenNode.createGenerator(container, options: options)
                    container.register(MeshGenerator.self, name: key!) { _ in
                        return meshGen.copy(container)
                        }.inObjectScope(.None)
                case .Camera:
                    let camera = SpectraXMLCameraNode().parse(container, elem: child, options: options)
                    container.register(MDLCamera.self, name: key!) { _ in
                        return SpectraXMLCameraNode.copy(camera)
                        }.inObjectScope(.None)
                case .StereoscopicCamera:
                    let stereoCam = SpectraXMLStereoscopicCameraNode().parse(container, elem: child, options: options)
                    container.register(MDLStereoscopicCamera.self, name: key!) { _ in
                        return SpectraXMLStereoscopicCameraNode.copy(stereoCam)
                        }.inObjectScope(.None)
                case .PhysicalLens:
                    let lensNode = PhysicalLensNode()
                    lensNode.parseXML(container, elem: child, options: options)
                    container.register(PhysicalLensNode.self, name: key!) { _ in
                        return (lensNode.copy() as! PhysicalLensNode)
                        }.inObjectScope(.None)
                case .PhysicalImagingSurface:
                    let imagingSurfaceNode = PhysicalImagingSurfaceNode()
                    imagingSurfaceNode.parseXML(container, elem: child, options: options)
                    container.register(PhysicalImagingSurfaceNode.self, name: key!) { _ in
                        return (imagingSurfaceNode.copy() as! PhysicalImagingSurfaceNode)
                        }.inObjectScope(.None)
                case .Transform:
                    let transform = SpectraXMLTransformNode().parse(container, elem: child, options: options)
                    container.register(MDLTransform.self, name: key!) { _ in
                        return SpectraXMLTransformNode.copy(transform)
                    }.inObjectScope(.None)
                case .Texture:
                    let textureNode = TextureNode()
                    textureNode.parseXML(container, elem: child, options: options)
                    let textureGen = container.resolve(TextureGenerator.self, name: textureNode.generator)!
                    let texture = textureGen.generate(container, args: textureNode.args)
                    container.register(MDLTexture.self, name: key!) { _ in
                        // don't copy texture
                        return texture
                    }
                case .TextureGenerator:
                    let texGenNode = TextureGeneratorNode()
                    texGenNode.parseXML(container, elem: child, options: options)
                    let texGen = texGenNode.createGenerator(container, options: options)
                    container.register(TextureGenerator.self, name: key!) { _ in
                        return texGen.copy(container)
                        }.inObjectScope(.None)
                case .TextureFilter:
                    let filterNode = TextureFilterNode()
                    filterNode.parseXML(container, elem: child, options: options)
                    let filter = filterNode.generate(container, options: options)
                    container.register(MDLTextureFilter.self, name: key!) { _ in
                        return TextureFilterNode.copy(filter)
                    }
                default: break
                }
                
                //TODO: use .dynamicType for meta type at run time
                // - nvm, "auto-injection" feature won't be in swinject until 2.0.0
                
                // TODO: use options to set ObjectScope (default to .Container?)
                
                // TODO: recursively resolve non-final types in tuple:
                // - i.e. if some monad returns instead of concrete value,
                //   - then try to resolve the monad (should metadata also be returned?)
                //   - this may be a feature to implement down the road
                // - it can be resolved by returning either a tuple with metadata
                //   - or a hash of [String: Any], but the tuple is superior
                //   - tuple: (SpectraMonadType, [String: Any])
                // - but i still would have to perform type resolution on the [String: Any]
                //   - if the tupal is to be useful and dynamic
                
            }
        }
    }
    
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

public protocol SpectraXMLNode {
    typealias NodeType
    
    func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType
}

public class AssetNode: NSObject, NSCopying {
    public var urlString: String?
    public var resource: String?
    public var vertexDescriptor: String = "default"
    public var bufferAllocator: String = "default"
    
    // TODO: error handling for preserveTopology 
    // - (when true the constructor throws. for now, my protocol can't handle this)
    public var preserveTopology: Bool = false
    
    // file formats:
    // - Alembic *.abc
    // - Wavefront Object *.obj
    // - Polygon *.abc
    // - Standard Tessellation Language *.stl
    
    public func parseXML(nodeContainer: Container, elem: XMLElement, options: [String: Any] = [:]) {
        
        if let urlString = elem.attributes["url"] {
            self.urlString = urlString
        }
        if let resource = elem.attributes["resource"] {
            self.resource = resource
        }
        
        var vertexDesc: MDLVertexDescriptor?
        
        let descSelector = "vertex-descriptor"
        if let vertexDescKey = elem.attributes["vertex-descriptor"] {
            self.vertexDescriptor = vertexDescKey
        } // TODO: else if contains a vertexDescriptor node
        
        if let bufferAllocKey = elem.attributes["buffer-allocator"] {
            self.bufferAllocator = bufferAllocKey
        }
        
        if let preserveTopology = elem.attributes["preserve-topology"] {
            let valAsBool = NSString(string: preserveTopology).boolValue
            self.preserveTopology = valAsBool
        }
    }
    
    public func generate(container: Container, options: [String: Any] = [:]) -> MDLAsset {
        
        let url = NSURL(string: self.url!)
        
//        if resource != nil {
//            // TODO: need to have access to bundles
//        }
        
        var vertexDescriptor = container.resolve(MDLVertexDescriptor.self, name: self.vertexDescriptor)
        var bufferAllocator = container.resolve(MDLMeshBufferAllocator.self, name: self.bufferAllocator)
        
        let asset = MDLAsset(URL: self.url!, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        
        // TODO: change to call with preserveTopology (it throws though)
        
        return asset
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let cp = AssetNode()
        cp.url = self.url
        cp.vertexDescriptor = self.vertexDescriptor
        cp.bufferAllocator = self.bufferAllocator
        return cp
    }
    
    public static func copy(obj: MDLAsset) -> MDLAsset {
        return obj.copy() as! MDLAsset
    }
}

public class SpectraXMLBufferAllocatorNode: SpectraXMLNode {
    public typealias NodeType = MDLMeshBufferAllocator
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any] =
[:]) -> NodeType {
        // TODO: add a MeshBufferAllocatorGenerator protocol
        // - with a generate function (also take an args: [String: GeneratorArg] = [:])
        // - instead of fetching from the container's MDLMeshBufferAllocator.self
        //   - we fetch from the MeshBufferAllocatorGenerator.self registration
        
        let alloc8: MDLMeshBufferAllocator?
        
        if let type = elem.attributes["type"] {
            alloc8 = container.resolve(MDLMeshBufferAllocator.self, name: type)
        } else {
            // TODO: add available mtl devices to a root container
            // - it will build, but it won't work
            let mtlDevice = container.resolve(MTLDevice.self, name: "default")!
            alloc8 = MTKMeshBufferAllocator(device: mtlDevice)
        }
        
        // TODO: how to assign other attributes of a buffer allocator?
        // - especially when users can define their own properties
        //   - mimic the mesh generation setup, so users can define args
        
        return alloc8!
    }
    
    // TODO: copy?  honestly, can a memory management object like this be copied?
    // - or at least efficiently copied in some meaningful way?  i think not
    // - no copies for you!
    //   - instead create a new registration and manage instances
    // - registrations for MDLMeshBufferAllocator.self manage instances
    // - and registration for MeshBufferAllocatorGenerators manage generator instances
    //   - and pop out new buffer allocators
    
}

public class SpectraXMLVertexAttributeNode: SpectraXMLNode {
    public typealias NodeType = MDLVertexAttribute
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any] = [:]) -> NodeType {
        let vertexAttr = MDLVertexAttribute()
        
        // TODO: determine which of these are required
        // TODO: abstract this logic, so if user overrides the closure,
        // - they don't need to reimplement basics
        
        if let name = elem.attributes["name"] {
            vertexAttr.name = name
        }
        if let format = elem.attributes["format"] {
            let enumVal = container.resolve(SpectraEnum.self, name: "mdlVertexFormat")!.getValue(format)
            vertexAttr.format = MDLVertexFormat(rawValue: enumVal)!
        }
        if let offset = elem.attributes["offset"] {
            vertexAttr.offset = Int(offset)!
        }
        if let bufferIndex = elem.attributes["buffer-index"] {
            vertexAttr.bufferIndex = Int(bufferIndex)!
        }
        if let initializationValue = elem.attributes["initialization-value"] {
            vertexAttr.initializationValue = SpectraSimd.parseFloat4(initializationValue)
        }
        
        return vertexAttr
    }
}

public class SpectraXMLVertexDescriptorNode: SpectraXMLNode {
    public typealias NodeType = MDLVertexDescriptor
    
    public func parse(container: Container, elem: XMLElement, options: [String : Any] = [:]) -> NodeType {
        var vertexDesc = MDLVertexDescriptor()
        
        // if user specified a parent descriptor, find it and copy it
        // - any named property will be overwritten
        if let parentDescriptor = elem.attributes["parent-descriptor"] {
            let parentDesc = container.resolve(MDLVertexDescriptor.self, name: parentDescriptor)!
            vertexDesc = MDLVertexDescriptor(vertexDescriptor: parentDesc)
        }
        
        let attributeSelector = "vertex-attributes > vertex-attribute"
        for (idx, el) in elem.css(attributeSelector).enumerate() {
            if let ref = el.attributes["ref"] {
                let vertexAttr = container.resolve(MDLVertexAttribute.self, name: ref)!
                vertexDesc.addOrReplaceAttribute(vertexAttr)
            } else {
                let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: el, options: options)
                vertexDesc.addOrReplaceAttribute(vertexAttr)
            }
        }
        
        // this automatically sets the offset correctly,
        // - but attributes must be assigned and configured by this point
        vertexDesc.setPackedOffsets()
        vertexDesc.setPackedStrides()
        
        return vertexDesc
    }
}

public class SpectraXMLTransformNode: SpectraXMLNode {
    public typealias NodeType = MDLTransform
    
    // TODO: time based translations?
    // TODO: reference other MDLTransforms & Compose (via declaration in XML)
    
    public func parse(container: Container, elem: XMLElement, options: [String : Any] = [:]) -> NodeType {
        var transform = MDLTransform()
        
        // N.B. scale first, then rotate, finally translate
        // - but how can a shear operation be composed into this?
        
        if let scale = elem.attributes["scale"] {
            transform.scale = SpectraSimd.parseFloat3(scale)
        }
        
        if let shear = elem.attributes["shear"] {
            transform.shear = SpectraSimd.parseFloat3(shear)
        }
        
        if let rotation = elem.attributes["rotation"] {
            transform.rotation = SpectraSimd.parseFloat3(rotation)
        } else if let rotationDeg = elem.attributes["rotation-deg"] {
            let rotationDegrees = SpectraSimd.parseFloat3(rotationDeg)
            transform.rotation = Float(M_PI / 180.0) * SpectraSimd.parseFloat3(rotationDeg)
        }
        
        if let translation = elem.attributes["translation"] {
            transform.translation = SpectraSimd.parseFloat3(translation)
        }
        // TODO: does the MDLTransform calculate the transformation matrix?
        // - or do i need to compose these values together
        
        return transform
    }
    
    public static func copy(object: NodeType) -> NodeType {
        let newTransform = MDLTransform()
        
        newTransform.scale = object.scale
        newTransform.shear = object.shear
        newTransform.rotation = object.rotation
        newTransform.translation = object.translation
        
        return newTransform
    }
}

public struct GeneratorArg {
    public var name: String
    public var type: String
    public var value: String
    
    public init(name: String, type: String, value: String) {
        self.name = name
        self.type = type
        self.value = value
    }
    
//    public func parseValue<T>() -> T? {
    
        // TODO: populate type enum
//        switch self.type {
//        case .Float: return Float(value) as! T
//        case .Float2: return SpectraSimd.parseFloat2(value) as! T
//        case .Float3: return SpectraSimd.parseFloat3(value) as! T
//        case .Float4: return SpectraSimd.parseFloat4(value) as! T
//        
//            
//        }

        // TODO: how to switch based on type
//        switch T.self {
//        case Float.self: return Float(value) as! T
//        case is float2: return (value) as! T
//        default: return nil
//        }
        
//    }
    
    // TODO: decide on whether this is really necessary to enumerate types
    // - node this can really be translated in the mesh generator
    public enum GeneratorArgType: String {
        case String = "String"
        case Float = "Float"
        case Float2 = "Float2"
        case Float3 = "Float3"
        case Float4 = "Float4"
        case Int = "Int"
        case Int2 = "Int2"
        case Int3 = "Int3"
        case Int4 = "Int4"
        case Mesh = "Mesh"
    }
}

// TODO: store sets of arguments in <generator-arg-set> tags?
// - make these monadic? so that values can be replaced?
// - make these composable?

public class MeshNode {
    public var generator: String = "ellipsoid_mesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    public func parseXML(container: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let generator = elem.attributes["mesh-generator"] {
            self.generator = generator
        }
        
        let generatorArgsSelector = "generator-args > generator-arg"
        for (idx, el) in elem.css(generatorArgsSelector).enumerate() {
            let name = el.attributes["name"]!
            let type = el.attributes["type"]!
            let value = el.attributes["value"]!
            args[name] = GeneratorArg(name: name, type: type, value: value)
        }
    }
}

public class MeshGeneratorNode {
    public var type: String = "tetrahedron_mesh_gen"
    public var args: [String: GeneratorArg] = [:]
    
    public func parseXML(container: Container, elem: XMLElement, options: [String : Any] = [:]) {
        if let type = elem.attributes["type"] {
            self.type = type
        }
        
        let meshGenArgsSelector = "generator-args > generator-arg"
        for (idx, el) in elem.css(meshGenArgsSelector).enumerate() {
            let name = el.attributes["name"]!
            let type = el.attributes["type"]!
            let value = el.attributes["value"]!
            
            args[name] = GeneratorArg(name: name, type: type, value: value)
        }
    }
    
    public func createGenerator(container: Container, options: [String : Any] = [:]) -> MeshGenerator {
        let meshGen = container.resolve(MeshGenerator.self, name: self.type)!
        meshGen.processArgs(container, args: self.args)
        return meshGen
    }
}

public class TextureNode {
    public var generator: String = "noise_texture_gen"
    public var args: [String: GeneratorArg] = [:]
    
    public func parseXML(container: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let generator = elem.attributes["generator"] {
            self.generator = generator
        }
        
        let generatorArgsSelector = "generator-args > generator-arg"
        for (idx, el) in elem.css(generatorArgsSelector).enumerate() {
            let name = el.attributes["name"]!
            let type = el.attributes["type"]!
            let value = el.attributes["value"]!
            args[name] = GeneratorArg(name: name, type: type, value: value)
        }
    }
}

public class TextureGeneratorNode {
    public var type: String = "noise_texture_gen"
    public var args: [String: GeneratorArg] = [:]
    
    public func parseXML(container: Container, elem: XMLElement, options: [String : Any] = [:]) {
        if let type = elem.attributes["type"] {
            self.type = type
        }
        
        let texGenArgsSelector = "generator-args > generator-arg"
        for (idx, el) in elem.css(texGenArgsSelector).enumerate() {
            let name = el.attributes["name"]!
            let type = el.attributes["type"]!
            let value = el.attributes["value"]!
            
            self.args[name] = GeneratorArg(name: name, type: type, value: value)
        }
    }
    
    public func createGenerator(container: Container, options: [String : Any] = [:]) -> TextureGenerator {
        let texGen = container.resolve(TextureGenerator.self, name: self.type)!
        texGen.processArgs(container, args: self.args)
        return texGen
    }
}


public class SpectraXMLObjectNode: SpectraXMLNode {
    public typealias NodeType = MDLObject
    
    public func parse(container: Container, elem: XMLElement, options: [String : Any] = [:]) -> NodeType {
        var object = MDLObject()
        
        if let name = elem.attributes["name"] {
            object.name = name
        }
        
        let transformSelector = SpectraXMLNodeType.Transform.rawValue
        if let transformTag = elem.firstChild(tag: transformSelector) {
            if let ref = transformTag.attributes["ref"] {
                let transform = container.resolve(MDLTransform.self, name: ref)!
                object.transform = transform
            } else {
                let transform = SpectraXMLTransformNode().parse(container, elem: transformTag, options: options)
                if let transformKey = transformTag.attributes["key"] {
                    container.register(MDLTransform.self, name: transformKey) { _ in
                        return SpectraXMLTransformNode.copy(transform)
                    }
                }
                object.transform = transform
            }
        }
        
        // NOTE: nodes should be parsed in order (searching for each type won't work)
        for (idx, el) in elem.children.enumerate() {
            let objKey = el.attributes["key"]
            let objRef = el.attributes["ref"]
            
            if let nodeType = SpectraXMLNodeType(rawValue: el.tag!) {
                switch nodeType {
                case .Object:
                    if let ref = objRef {
                        let obj = container.resolve(MDLObject.self, name: ref)!
                        object.addChild(obj)
                    } else {
                        let obj = SpectraXMLObjectNode().parse(container, elem: el, options: options)
                        if let key = objKey {
                            container.register(MDLObject.self, name: key) { _ in
                                return SpectraXMLObjectNode.copy(obj)
                            }
                        }
                        object.addChild(obj)
                    }
                    
                // set parent??
                case .Camera:
                    if let ref = objRef {
                        let cam = container.resolve(MDLCamera.self, name: ref)!
                        object.addChild(cam)
                    } else {
                        let cam = SpectraXMLCameraNode().parse(container, elem: el, options: options)
                        if let key = objKey {
                            container.register(MDLCamera.self, name: key) { _ in
                                return SpectraXMLCameraNode.copy(cam)
                            }
                        }
                    }
                    
                case .StereoscopicCamera:
                    if let ref = objRef {
                        let cam = container.resolve(MDLStereoscopicCamera.self, name: ref)!
                        object.addChild(cam)
                    } else {
                        let cam = SpectraXMLStereoscopicCameraNode().parse(container, elem: el, options: options)
                        if let key = objKey {
                            container.register(MDLStereoscopicCamera.self, name: key) { _ in
                                return SpectraXMLStereoscopicCameraNode.copy(cam)
                            }
                        }
                    }
                    
                case .Light: break
                case .Mesh: break
                default: break
                }
                
            } else {
                // parse other nodes (custom nodes, etc)
            }
        }
        
        return object
    }
    
    public static func copy(object: NodeType) -> NodeType {
        let cp = MDLObject()

        cp.name = object.name.copy() as! String
        
        if let transform = object.transform {
            if transform is MDLTransform {
                cp.transform = SpectraXMLTransformNode.copy(object.transform! as! MDLTransform)
            } else {
                // TODO: fix the copy by reference
                cp.transform = object.transform
            }
        }
        
        if let objContainer = object.componentConformingToProtocol(MDLObjectContainerComponent.self) {
            // strange that an object with no children returns nil,
            // - yet the compiler thinks this is impossible
            
            if object.children.objects.count > 0 {
                for obj in object.children.objects {
                    switch obj {
                    case is MDLCamera:
                        cp.addChild(SpectraXMLCameraNode.copy(obj as! MDLCamera))
                    case is MDLStereoscopicCamera:
                        cp.addChild(SpectraXMLStereoscopicCameraNode.copy(obj as! MDLStereoscopicCamera))
                    case is MDLLight: break
                    case is MDLMesh: break
                    default:
                        //TODO: account for case when obj is subclass of MDLObject, but not MDLObject
                        // - can't use (obj is MDLObject) or !(obj is MDLObject) bc that's always true/false
                        cp.addChild(SpectraXMLObjectNode.copy(obj))
                    }
                }
            }
        }
        
        return cp
    }
}

//============================================================
// TODO: decide how to handle inheritance
// - use separate node classes for each instance
//   - this would be appropriate for some, like MDLCamera & Stereoscopic (except phys lens & phys imaging)
//   - but gets cumbersome for other classes, like MDLTexture, etc.
//   - and isn't extensible
// - there's also the mesh-generator pattern from the original SceneGraphXML
//   - this draws from a map of monads passed in and executes the one for a specific type, if found

public class PhysicalLensNode: NSObject, NSCopying {
    // for any of this to do anything, renderer must support the math (visual distortion, etc)
    
    public var worldToMetersConversionScale: Float?
    public var barrelDistortion: Float?
    public var fisheyeDistortion: Float?
    public var opticalVignetting: Float?
    public var chromaticAberration: Float?
    public var focalLength: Float?
    public var fStop: Float?
    public var apertureBladeCount: Int?
    public var maximumCircleOfConfusion: Float?
    public var focusDistance: Float?
    
    // defaults
    public static let worldToMetersConversionScale: Float = 1.0
    public static let barrelDistortion: Float = 0
    public static let fisheyeDistortion: Float = 0
    public static let opticalVignetting: Float = 0
    public static let chromaticAberration: Float = 0
    public static let focalLength: Float = 50
    public static let fStop: Float = 5.6
    public static let apertureBladeCount: Int = 0
    public static let maximumCircleOfConfusion: Float = 0.05
    public static let focusDistance: Float = 2.5
    
    // doc's don't list default shutterOpenInterval value,
    // - but (1/60) * 0.50 = 1/120 for 60fps and 50% shutter
    public var shutterOpenInterval: NSTimeInterval = (0.5 * (1.0/60.0))
    
    public func parseXML(container: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let worldToMetersConversionScale = elem.attributes["world-to-meters-conversion-scale"] {
            self.worldToMetersConversionScale = Float(worldToMetersConversionScale)!
        }
        
        if let barrelDistortion = elem.attributes["barrel-distortion"] {
            self.barrelDistortion = Float(barrelDistortion)!
        }
        
        if let fisheyeDistortion = elem.attributes["fisheye-distortion"] {
            self.fisheyeDistortion = Float(fisheyeDistortion)!
        }
        
        if let opticalVignetting = elem.attributes["optical-vignetting"] {
            self.opticalVignetting = Float(opticalVignetting)!
        }
        
        if let chromaticAberration = elem.attributes["chromatic-aberration"] {
            self.chromaticAberration = Float(chromaticAberration)!
        }
        
        if let focalLength = elem.attributes["focal-length"] {
            self.focalLength = Float(focalLength)!
        }
        
        if let fStop = elem.attributes["f-stop"] {
            self.fStop = Float(fStop)!
        }
        
        if let apertureBladeCount = elem.attributes["aperture-blade-count"] {
            self.apertureBladeCount = Int(apertureBladeCount)!
        }
        
        if let maximumCircleOfConfusion = elem.attributes["maximum-circle-of-confusion"] {
            self.maximumCircleOfConfusion = Float(maximumCircleOfConfusion)!
        }
        
        if let focusDistance = elem.attributes["focus-distance"] {
            self.focusDistance = Float(focusDistance)!
        }
    }
    
    public func applyToCamera(camera: MDLCamera) {
        
        if let val = self.worldToMetersConversionScale {
            camera.worldToMetersConversionScale = val
        }
        
        if let val = self.barrelDistortion {
            camera.barrelDistortion = val
        }
        
        if let val = self.fisheyeDistortion {
            camera.fisheyeDistortion = val
        }
        
        if let val = self.opticalVignetting {
            camera.opticalVignetting = val
        }
        
        if let val = self.chromaticAberration {
            camera.chromaticAberration = val
        }
        
        if let val = self.focalLength {
            camera.focalLength = val
        }
        
        if let val = self.fStop {
            camera.fStop = val
        }
        
        if let val = self.apertureBladeCount {
            camera.apertureBladeCount = val
        }
        
        if let val = self.maximumCircleOfConfusion {
            camera.maximumCircleOfConfusion = val
        }
        
        if let val = self.focusDistance {
            camera.focusDistance = val
        }
        
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let cp = PhysicalLensNode()
        cp.worldToMetersConversionScale = self.worldToMetersConversionScale
        cp.barrelDistortion = self.barrelDistortion
        cp.fisheyeDistortion = self.fisheyeDistortion
        cp.opticalVignetting = self.opticalVignetting
        cp.chromaticAberration = self.chromaticAberration
        cp.focalLength = self.focalLength
        cp.fStop = self.fStop
        cp.apertureBladeCount = self.apertureBladeCount
        cp.maximumCircleOfConfusion = self.maximumCircleOfConfusion
        cp.focusDistance = self.focusDistance
        return cp
    }
}

public class PhysicalImagingSurfaceNode: NSObject, NSCopying {
    // for any of this to do anything, renderer must support the math (visual distortion, etc)
    
    public var sensorVerticalAperture: Float?
    public var sensorAspect: Float?
    public var sensorEnlargement: vector_float2?
    public var sensorShift: vector_float2?
    public var flash: vector_float3?
    public var exposure: vector_float3?
    public var exposureCompression: vector_float2?
    
    // defaults
    public static let sensorVerticalAperture: Float = 24
    public static let sensorAspect: Float = 1.5
    public static let sensorEnlargement: vector_float2 = float2(1.0, 1.0)
    public static let sensorShift: vector_float2 = float2(0.0, 0.0)
    public static let flash: vector_float3 = float3(0.0, 0.0, 0.0)
    public static let exposure: vector_float3 = float3(1.0, 1.0, 1.0)
    public static let exposureCompression: vector_float2 = float2(1.0, 0.0)
    
    public func parseXML(container: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let sensorVerticalAperture = elem.attributes["sensor-vertical-aperture"] {
            self.sensorVerticalAperture = Float(sensorVerticalAperture)
        }
        
        if let sensorAspect = elem.attributes["sensor-aspect"] {
            self.sensorAspect = Float(sensorAspect)
        }
        
        if let sensorEnlargement = elem.attributes["sensor-enlargement"] {
            self.sensorEnlargement = SpectraSimd.parseFloat2(sensorEnlargement)
        }
        
        if let sensorShift = elem.attributes["sensor-shift"] {
            self.sensorShift = SpectraSimd.parseFloat2(sensorShift)
        }
        
        if let flash = elem.attributes["flash"] {
            self.flash = SpectraSimd.parseFloat3(flash)
        }
        
        if let exposure = elem.attributes["exposure"] {
            self.exposure = SpectraSimd.parseFloat3(exposure)
        }
        
        if let exposureCompression = elem.attributes["exposure-compression"] {
            self.exposureCompression = SpectraSimd.parseFloat2(exposureCompression)
        }
    }
    
    public func applyToCamera(camera: MDLCamera) {
        
        if let val = self.sensorVerticalAperture {
            camera.sensorVerticalAperture = val
        }
        
        if let val = self.sensorAspect {
            camera.sensorAspect = val
        }
        
        if let val = self.sensorEnlargement {
            camera.sensorEnlargement = val
        }
        
        if let val = self.sensorShift {
            camera.sensorShift = val
        }
        
        if let val = self.flash {
            camera.flash = val
        }
        
        if let val = self.exposure {
            camera.exposure = val
        }
        
        if let val = self.exposureCompression {
            camera.exposureCompression = val
        }
        
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let cp = PhysicalImagingSurfaceNode()
        cp.sensorVerticalAperture = self.sensorVerticalAperture
        cp.sensorAspect = self.sensorAspect
        cp.sensorEnlargement = self.sensorEnlargement
        cp.sensorShift = self.sensorShift
        cp.flash = self.flash
        cp.exposure = self.exposure
        cp.exposureCompression = self.exposureCompression
        
        return cp
    }
}

public class SpectraXMLCameraNode: SpectraXMLNode {
    public typealias NodeType = MDLCamera
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any] = [:]) -> NodeType {
        let cam = NodeType()
        
        // TODO: the following are required.  make them optional with defaults?
        if let nearVisibility = elem.attributes["near-visibility-distance"] {
            cam.nearVisibilityDistance = Float(nearVisibility)!
        }
        if let farVisibility = elem.attributes["far-visibility-distance"] {
            cam.farVisibilityDistance = Float(farVisibility)!
        }
        if let fieldOfView = elem.attributes["field-of-view"] {
            cam.fieldOfView = Float(fieldOfView)!
        }
        
        let lensSelector = SpectraXMLNodeType.PhysicalLens.rawValue
        if let lensTag = elem.firstChild(tag: lensSelector) {
            if let ref = lensTag.attributes["ref"] {
                let lens = container.resolve(PhysicalLensNode.self, name: ref)!
                lens.applyToCamera(cam)
            } else {
                let lensNode = PhysicalLensNode()
                lensNode.parseXML(container, elem: lensTag, options: options)
                if let lensKey = lensTag["key"] {
                    container.register(PhysicalLensNode.self, name: lensKey) { _ in return
                        lensNode.copy() as! PhysicalLensNode
                    }
                }
                lensNode.applyToCamera(cam)
            }
        }
        
        let imagingSelector = SpectraXMLNodeType.PhysicalImagingSurface.rawValue
        if let imagingTag = elem.firstChild(tag: imagingSelector) {
            if let ref = imagingTag.attributes["ref"] {
                let imagingSurface = container.resolve(PhysicalImagingSurfaceNode.self, name: ref)!
                imagingSurface.applyToCamera(cam)
            } else {
                let imagingSurfaceNode = PhysicalImagingSurfaceNode()
                imagingSurfaceNode.parseXML(container, elem: imagingTag, options: options)
                if let imagingSurfaceKey = imagingTag["key"] {
                    container.register(PhysicalImagingSurfaceNode.self, name: imagingTag["key"]!) { _ in
                        return imagingSurfaceNode.copy() as! PhysicalImagingSurfaceNode
                    }
                }
                imagingSurfaceNode.applyToCamera(cam)
            }
        }
        
        if let lookAtAttr = elem.attributes["look-at"] {
            let lookAt = SpectraSimd.parseFloat3(lookAtAttr)
            if let lookFromAttr = elem.attributes["look-from"] {
                let lookFrom = SpectraSimd.parseFloat3(lookFromAttr)
                cam.lookAt(lookAt, from: lookFrom)
            } else {
                cam.lookAt(lookAt)
            }
        }
        
        return cam
    }
    
    public static func copy(object: NodeType) -> NodeType {
        let newCam = MDLCamera()
        newCam.nearVisibilityDistance = object.nearVisibilityDistance
        newCam.farVisibilityDistance = object.farVisibilityDistance
        newCam.fieldOfView = object.fieldOfView
        
        // physical lens
        newCam.worldToMetersConversionScale = object.worldToMetersConversionScale
        newCam.barrelDistortion = object.barrelDistortion
        newCam.fisheyeDistortion = object.fisheyeDistortion
        newCam.opticalVignetting = object.opticalVignetting
        newCam.chromaticAberration = object.chromaticAberration
        newCam.focalLength = object.focalLength
        newCam.fStop = object.fStop
        newCam.apertureBladeCount = object.apertureBladeCount
        newCam.maximumCircleOfConfusion = object.maximumCircleOfConfusion
        newCam.focusDistance = object.focusDistance
        
        // physical imaging surface
        newCam.sensorVerticalAperture = object.sensorVerticalAperture
        newCam.sensorAspect = object.sensorAspect
        newCam.sensorEnlargement = object.sensorEnlargement
        newCam.sensorShift = object.sensorShift
        newCam.flash = object.flash
        newCam.exposure = object.exposure
        newCam.exposureCompression = object.exposureCompression
        
        return newCam
    }
}

public class SpectraXMLStereoscopicCameraNode: SpectraXMLNode {
    public typealias NodeType = MDLStereoscopicCamera
    
    public func parse(container: Container, elem: XMLElement, options: [String : Any] = [:]) -> NodeType {
        let cam = SpectraXMLCameraNode().parse(container, elem: elem, options: options)
        let stereoCam = convertCameraToStereoscopic(cam)
        
        if let interPupillaryDistance = elem.attributes["inter-pupillary-distance"] {
            stereoCam.interPupillaryDistance = Float(interPupillaryDistance)!
        }
        
        if let leftVergence = elem.attributes["left-vergence"] {
            stereoCam.leftVergence = Float(leftVergence)!
        }
        
        if let rightVergence = elem.attributes["right-vergence"] {
            stereoCam.rightVergence = Float(rightVergence)!
        }
        
        if let overlap = elem.attributes["overlap"] {
            stereoCam.overlap = Float(overlap)!
        }
        
        return stereoCam
    }
    
    public func convertCameraToStereoscopic(cam: MDLCamera) -> MDLStereoscopicCamera {
        // There has to be a better way to do this!
        // (downcasting cam as! stereocam failed)
        let stereoCam = MDLStereoscopicCamera()
        stereoCam.nearVisibilityDistance = cam.nearVisibilityDistance
        stereoCam.farVisibilityDistance = cam.farVisibilityDistance
        stereoCam.fieldOfView = cam.fieldOfView
        
        // physical lens
        stereoCam.worldToMetersConversionScale = cam.worldToMetersConversionScale
        stereoCam.barrelDistortion = cam.barrelDistortion
        stereoCam.fisheyeDistortion = cam.fisheyeDistortion
        stereoCam.opticalVignetting = cam.opticalVignetting
        stereoCam.chromaticAberration = cam.chromaticAberration
        stereoCam.focalLength = cam.focalLength
        stereoCam.fStop = cam.fStop
        stereoCam.apertureBladeCount = cam.apertureBladeCount
        stereoCam.maximumCircleOfConfusion = cam.maximumCircleOfConfusion
        stereoCam.focusDistance = cam.focusDistance
        
        // physical imaging surface
        stereoCam.sensorVerticalAperture = cam.sensorVerticalAperture
        stereoCam.sensorAspect = cam.sensorAspect
        stereoCam.sensorEnlargement = cam.sensorEnlargement
        stereoCam.sensorShift = cam.sensorShift
        stereoCam.flash = cam.flash
        stereoCam.exposure = cam.exposure
        stereoCam.exposureCompression = cam.exposureCompression
        
        return stereoCam
    }
    
    public static func copy(object: NodeType) -> NodeType {
        let newCam = MDLStereoscopicCamera()
        newCam.nearVisibilityDistance = object.nearVisibilityDistance
        newCam.farVisibilityDistance = object.farVisibilityDistance
        newCam.fieldOfView = object.fieldOfView
        
        // stereoscopic
        newCam.interPupillaryDistance = object.interPupillaryDistance
        newCam.leftVergence = object.leftVergence
        newCam.rightVergence = object.rightVergence
        newCam.overlap = object.overlap
        
        // physical lens
        newCam.worldToMetersConversionScale = object.worldToMetersConversionScale
        newCam.barrelDistortion = object.barrelDistortion
        newCam.fisheyeDistortion = object.fisheyeDistortion
        newCam.opticalVignetting = object.opticalVignetting
        newCam.chromaticAberration = object.chromaticAberration
        newCam.focalLength = object.focalLength
        newCam.fStop = object.fStop
        newCam.apertureBladeCount = object.apertureBladeCount
        newCam.maximumCircleOfConfusion = object.maximumCircleOfConfusion
        newCam.focusDistance = object.focusDistance
        
        // physical imaging surface
        newCam.sensorVerticalAperture = object.sensorVerticalAperture
        newCam.sensorAspect = object.sensorAspect
        newCam.sensorEnlargement = object.sensorEnlargement
        newCam.sensorShift = object.sensorShift
        newCam.flash = object.flash
        newCam.exposure = object.exposure
        newCam.exposureCompression = object.exposureCompression
        
        return newCam
    }
}

public class TextureFilterNode: NSObject, NSCopying {
    public var rWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var tWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var sWrapMode = MDLMaterialTextureWrapMode.Clamp
    public var minFilter = MDLMaterialTextureFilterMode.Nearest
    public var magFilter = MDLMaterialTextureFilterMode.Nearest
    public var mipFilter = MDLMaterialMipMapFilterMode.Nearest
    
    public func parseXML(nodeContainer: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let rWrap = elem.attributes["r-wrap-mode"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(rWrap)
            self.rWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let tWrap = elem.attributes["t-wrap-mode"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(tWrap)
            self.tWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let sWrap = elem.attributes["s-wrap-mode"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialTextureWrapMode")!.getValue(sWrap)
            self.sWrapMode = MDLMaterialTextureWrapMode(rawValue: enumVal)!
        }
        if let minFilter = elem.attributes["min-filter"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialTextureFilterMode")!.getValue(minFilter)
            self.minFilter = MDLMaterialTextureFilterMode(rawValue: enumVal)!
        }
        if let magFilter = elem.attributes["mag-filter"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialTextureFilterMode")!.getValue(magFilter)
            self.magFilter = MDLMaterialTextureFilterMode(rawValue: enumVal)!
        }
        if let mipFilter = elem.attributes["mip-filter"] {
            let enumVal = nodeContainer.resolve(SpectraEnum.self, name: "mdlMaterialMipMapFilterMode")!.getValue(mipFilter)
            self.mipFilter = MDLMaterialMipMapFilterMode(rawValue: enumVal)!
        }
    }
    
    public func generate(container: Container, options: [String: Any]) -> MDLTextureFilter {
        let filter = MDLTextureFilter()
    
        filter.rWrapMode = self.rWrapMode
        filter.tWrapMode = self.tWrapMode
        filter.sWrapMode = self.sWrapMode
        filter.minFilter = self.minFilter
        filter.magFilter = self.magFilter
        filter.mipFilter = self.mipFilter
    
        return filter
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let cp = TextureFilterNode()
        
        cp.rWrapMode = self.rWrapMode
        cp.tWrapMode = self.tWrapMode
        cp.sWrapMode = self.sWrapMode
        cp.minFilter = self.minFilter
        cp.magFilter = self.magFilter
        cp.mipFilter = self.mipFilter
        
        return cp
    }
    
    public static func copy(obj: MDLTextureFilter) -> MDLTextureFilter {
        let cp = MDLTextureFilter()
        
        cp.rWrapMode = obj.rWrapMode
        cp.tWrapMode = obj.tWrapMode
        cp.sWrapMode = obj.sWrapMode
        cp.minFilter = obj.minFilter
        cp.magFilter = obj.magFilter
        cp.mipFilter = obj.mipFilter
        
        return cp
    }
}

public class TextureSamplerNode: NSObject, NSCopying {
    public var texture: String?
    public var hardwareFilter: String?
    public var transform: String?
    
    // public func parseJSON()
    // public func parsePlist()
    // public func parseXML(nodeContainer: Container)
    
    // so, as above ^^^ there would instead be a nodeContainer, for parsing SpectraXML
    // - this would just contain very easily copyable definitions of nodes - no Model I/O
    // - these nodes could also instead be structs
    // - these nodes could generate the Model I/O, whenever app developer wants
    //   - the generate method would instead receive a different container.
    //     - but, does this really work? 
    //     - (parsing works now because it's assumed 
    //     - to proceed in the order which things are declared)
    // - having a separate nodeContainer ensures that each dependency registered
    //   - can be totally self-contained
    
    public func parseXML(nodeContainer: Container, elem: XMLElement, options: [String: Any] = [:]) {
        if let texture = elem.attributes["texture"] {
            self.texture = texture
        }
        if let hardwareFilter = elem.attributes["hardware-filter"] {
            self.hardwareFilter = hardwareFilter
        }
        if let transform = elem.attributes["transform"] {
            self.transform = transform
        }
    }
    
    public func generate(container: Container, options: [String: Any] = [:]) -> MDLTextureSampler {
        
        let sampler = MDLTextureSampler()
        sampler.texture = container.resolve(MDLTexture.self, name: self.texture)
        sampler.hardwareFilter = container.resolve(MDLTextureFilter.self, name: self.texture)
        if let transform = container.resolve(MDLTransform.self, name: self.transform) {
            sampler.transform = transform
        } else {
            sampler.transform = MDLTransform()
        }
        
        return sampler
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let cp = TextureSamplerNode()
        cp.texture = self.texture
        cp.hardwareFilter = self.hardwareFilter
        cp.transform = self.transform
        return cp
    }
    
    // implemented copy() as a static method for compatibility for now
    public static func copy(obj: MDLTextureSampler) -> MDLTextureSampler {
        let cp = MDLTextureSampler()
        cp.texture = obj.texture // can't really copy textures for resource reasons
        cp.transform = obj.transform ?? MDLTransform()
        if let filter = obj.hardwareFilter {
            cp.hardwareFilter = TextureFilterNode.copy(filter)
        }
        return cp
    }
}

// TODO: public class SpectraXMLLightNode: SpectraXMLNode {
// TODO: public class SpectraXML ... etc
// TODO: public class SpectraXMLMaterialNode: SpectraXMLNode {
// TODO: public class SpectraXMLMaterialPropertyNode: SpectraXMLNode {
// TODO: public class SpectraXMLScatteringFunctionNode: SpectraXMLNode {
// TODO: public class .. voxel array?  maybe a generator
// TODO: public class .. voxel morphism (morphology in 3D)

public class SpectraEnum {
    let name: String
    var values: [String: UInt]
    
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
    
    public func getValue(key: String) -> UInt {
        return values[key]!
    }
}

// TODO: is there struct value that makes sense here?
// - so, like a single struct value that can be used in case statements
// - but also carries a bit of info about the params of each type?
public enum SpectraVertexAttrType: String {
    // raw values for enums must be literals,
    // - so i can't use the MDLVertexAttribute string values
    case Anisotropy = "anisotropy"
    case Binormal = "binormal"
    case Bitangent = "bitangent"
    case Color = "color"
    case EdgeCrease = "edgeCrease"
    case JointIndices = "jointIndices"
    case JointWeights = "jointWeights"
    case Normal = "normal"
    case OcclusionValue = "occlusionValue"
    case Position = "position"
    case ShadingBasisU = "shadingBasisU"
    case ShadingBasisV = "shadingBasisV"
    case SubdivisionStencil = "subdivisionStencil"
    case Tangent = "tangent"
    case TextureCoordinate = "textureCoordinate"
    
    // can't add this to the SpectraEnums.xsd schema,
    // - at least not directly, since it's not an enum
}

public class SpectraXSD {
    public var xsd: XMLDocument?
    
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
        let bundle = NSBundle(forClass: S3DXSD.self)
        let path = bundle.pathForResource(filename, ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    public func parseEnumTypes(container: Container) {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        
        for enumChild in xsd!.css(enumTypesSelector) {
            let enumType = SpectraEnum(elem: enumChild)
            container.register(SpectraEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
    }
}
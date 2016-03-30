//
//  Parser.swift
//  
//
//  Created by David Conner on 3/9/16.
//
//

import Foundation
import Swinject
import Fuzi
import ModelIO

// GeneratorClosure =~ RegisterClosure
// - they both transform the containers and options passed into generate & register
// - they're both optional
// - i need some way for each node type to "declare" the options it needs to be available
//   - as well as a function for default transformation 4 resolving params from [String: Container]

// problems: how to pass the GeneratorClosures down through the tree of nodes (if necessary)
// - for now, just passing nil down the tree, but allowing the following order for resolving params for generate
//   - (1) if closure exists, run & set params from the resulting Container Map & Options Map.
//     - this closure is only passed to the top level node for now.  
//     - it's possible to pass thru to the child nodes.  maybe later
//     - need a kind of inverted-map structure for options
//   - (2) if not, then if necessary params are defined in the Options Map, set the params 4 generate from those
//     - how to distinguish the params defined in option for a parent node and child nodes
//   - (3) otherwise, run the default behavior for fetching params from Container Map
// ...
public typealias GeneratorClosure = ((containers: [String: Container], options: [String: Any]) -> (containers: [String: Container], options: [String: Any]))
public typealias RegisterClosure = (containers: [String: Container], options: [String: Any]) -> (containers: [String: Container], options: [String: Any])

public protocol SpectraParserNode {
    associatedtype NodeType
    associatedtype MDLType
    
    var id: String? { get set }
    // requires init() for copy()
    init(nodes: Container, elem: XMLElement)
    func parseXML(nodes: Container, elem: XMLElement)
    func generate(containers: [String: Container],
        options: [String: Any],
        injector: GeneratorClosure?) -> MDLType
    func register(nodes: Container, objectScope: ObjectScope)
    func copy() -> NodeType
}

extension SpectraParserNode {
    public func register(nodes: Container, objectScope: ObjectScope = .None) {
        let nodeCopy = self.copy()
        nodes.register(NodeType.self, name: self.id!) { _ in
            return nodeCopy
            }.inObjectScope(objectScope)
    }
}

public class SpectraParser {
    public var nodes: Container
    
    public init(nodes: Container = Container()) {
        self.nodes = nodes
    }
    
    public func getAsset(id: String?) -> AssetNode? {
        return nodes.resolve(AssetNode.self, name: id)
    }
    
    public func getVertexAttribute(id: String?) -> VertexAttributeNode? {
        return nodes.resolve(VertexAttributeNode.self, name: id)
    }
    
    public func getVertexDescriptor(id: String?) -> VertexDescriptorNode? {
        return nodes.resolve(VertexDescriptorNode.self, name: id)
    }
    
    public func getTransform(id: String?) -> TransformNode? {
        return nodes.resolve(TransformNode.self, name: id)
    }
    
    public func getObject(id: String?) -> ObjectNode? {
        return nodes.resolve(ObjectNode.self, name: id)
    }
    
    public func getPhysicalLens(id: String?) -> PhysicalLensNode? {
        return nodes.resolve(PhysicalLensNode.self, name: id)
    }
    
    public func getPhysicalImagingSurface(id: String?) -> PhysicalImagingSurfaceNode? {
        return nodes.resolve(PhysicalImagingSurfaceNode.self, name: id)
    }
    
    public func getCamera(id: String?) -> CameraNode? {
        return nodes.resolve(CameraNode.self, name: id)
    }
    
    public func getStereoscopicCamera(id: String?) -> StereoscopicCameraNode? {
        return nodes.resolve(StereoscopicCameraNode.self, name: id)
    }
    
    public func getMesh(id: String?) -> MeshNode? {
        return nodes.resolve(MeshNode.self, name: id)
    }
    
    public func getMeshGenerator(id: String?) -> MeshGeneratorNode? {
        return nodes.resolve(MeshGeneratorNode.self, name: id)
    }
    
    public func getSubmesh(id: String?) -> SubmeshNode? {
        return nodes.resolve(SubmeshNode.self, name: id)
    }
    
    public func getSubmeshGenerator(id: String?) -> SubmeshGeneratorNode? {
        return nodes.resolve(SubmeshGeneratorNode.self, name: id)
    }
    
    public func getTexture(id: String?) -> TextureNode? {
        return nodes.resolve(TextureNode.self, name: id)
    }
    
    public func getTextureGenerator(id: String?) -> TextureGeneratorNode? {
        return nodes.resolve(TextureGeneratorNode.self, name: id)
    }
    
    public func getTextureFilter(id: String?) -> TextureFilterNode? {
        return nodes.resolve(TextureFilterNode.self, name: id)
    }
    
    public func getTextureSampler(id: String?) -> TextureSamplerNode? {
        return nodes.resolve(TextureSamplerNode.self, name: id)
    }
    
    // TODO: Material
    // TODO: MaterialProperty
    // TODO: ScatteringFunction
    // TODO: Light
    // TODO: LightGenerator

//    public func get(id: String?) -> Node? {
//        return nodes.resolve(Node.self, name: id)
//    }
    
    // public func parseJSON()
    // public func parsePList()
    
    public func parseXML(xml: XMLDocument) {
        for child in xml.root!.children {
            let (tag, id) = (child.tag!, child.attributes["id"])
            
            // TODO: how to refactor this giant switch statement
            if let nodeType = SpectraNodeType(rawValue: tag) {
                
                switch nodeType {
                case .Asset:
                    let node = AssetNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .VertexAttribute:
                    let node = VertexAttributeNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .VertexDescriptor:
                    let node = VertexDescriptorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Transform:
                    let node = TransformNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
//                case .Object:
//                    let node = ObjectNode(nodes: nodes, elem: child)
//                    if (node.id != nil) { node.register(nodes) }
                case .PhysicalLens:
                    let node = PhysicalLensNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .PhysicalImagingSurface:
                    let node = PhysicalImagingSurfaceNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Camera:
                    let node = CameraNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .StereoscopicCamera:
                    let node = StereoscopicCameraNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Mesh:
                    let node = MeshNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .MeshGenerator:
                    let node = MeshGeneratorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Submesh:
                    let node = SubmeshNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .SubmeshGenerator:
                    let node = SubmeshGeneratorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .Texture:
                    let node = TextureNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .TextureGenerator:
                    let node = TextureGeneratorNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
                case .TextureFilter:
                    let node = TextureFilterNode(nodes: nodes, elem: child)
                    if (node.id != nil) { node.register(nodes) }
//                case .TextureSampler: break
//                case .Material: break
//                case .MaterialProperty: break
//                case .ScatteringFunction: break
//                case .Light: break
//                case .LightGenerator: break
                default: break
                }
            }
        }
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

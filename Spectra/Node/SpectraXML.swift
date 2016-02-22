//
//  SpectraXML.swift
//  
//
//  Created by David Conner on 2/22/16.
//
//

import Foundation

enum SpectraXMLNodes {
    case View = "view"
    case Perspective = "perspective"
    case Camera = "camera"
    case VertexDescriptor = "vertex-descriptor"
    case VertexAttribute = "vertex-attribute"
    case Mesh = "mesh"
}

class SpectraXML {
    
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

    //TODO: enum for node types
    
    public func parse(container: Container, options: [String: AnyObject] = [:]) {
        
    }
    
}

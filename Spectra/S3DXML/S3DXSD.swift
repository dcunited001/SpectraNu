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

//
//  main.swift
//  SpectraTasks
//
//  Created by David Conner on 2/22/16.
//  Copyright © 2016 Spectra. All rights reserved.
//

import Foundation

// .. hey, it works.  and it's better than handcoding this stuff

// configure arguments for the SpectraTasks target in xcode schemas
let projectPath = Process.arguments[1]

// filename is relative to Spectra-OSX
func updateSpectraEnums(filepath: String, enums: [String: [String: UInt]]) {
    let xsdEnums = enums.reduce("") { (memo, enumDef) in return memo + simpleTypeForEnum(enumDef.0, members: enumDef.1) }
    let spectraEnumSchema = xsdSchema("SpectraEnums", targetNamespace: "SpectraEnums", content: xsdEnums)

    do {
        try spectraEnumSchema.writeToFile(filepath, atomically: false, encoding: NSUTF8StringEncoding)
    } catch let ex as NSError {
        print(ex.localizedDescription)
        print("k pasta")
    }
}

// NOTE: i didn't want to add another dependency to my project
// - and my xml reader doesn't write.  and i don't feel like using NSXML ish
// - wtf no multiline strings?
func xsdSchema(xlmns: String, targetNamespace: String, content: String) -> String {
    return "<?xml version=\"1.0\"?>\n<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" " +
        "targetNamespace=\"\(targetNamespace)\" " +
        "xmlns=\"\(xlmns)\" elementFormDefault=\"qualified\">\n\n" + content +
        "\n\n</xs:schema>"
}

func xsSimpleType(name:String, content: String, mtlEnum: Bool = false) -> String {
    let mtlEnumAttr = mtlEnum ? " mtl-enum=\"true\"" : ""
    return "  <xs:simpleType name=\"\(name)\"\(mtlEnumAttr)>\n\(content)  </xs:simpleType>\n\n"
}

func xsMtlEnum(members: [String: UInt]) -> String {
    let content = members.reduce("\n") { (memo, member) in return "\(memo)      <xs:enumeration id=\"\(member.1)\" value=\"\(member.0)\"/>\n" }
    return "    <xs:restriction base=\"xs:string\">\(content)    </xs:restriction>\n"
}

func simpleTypeForEnum(name: String, members: [String: UInt]) -> String {
    let content = xsMtlEnum(members)
    return xsSimpleType(name, content: content, mtlEnum: true)
}

let enumsForModelIO = [
    "mdlVertexFormat": SpectraEnumDefs.mdlVertexFormat
]

updateSpectraEnums(projectPath + "/../SpectraAssets/SpectraEnums.xsd", enums: enumsForModelIO)

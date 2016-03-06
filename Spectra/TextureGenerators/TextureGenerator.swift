//
//  TextureGenerator.swift
//  
//
//  Created by David Conner on 3/5/16.
//
//

import Foundation

public protocol TextureGenerator {
    init(container: Container, args: [String: GeneratorArg])
    func generate(container: Container, args: [String: GeneratorArg])
}


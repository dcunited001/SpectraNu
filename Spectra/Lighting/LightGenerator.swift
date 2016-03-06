//
//  LightGenerator.swift
//  
//
//  Created by David Conner on 3/6/16.
//
//

import Foundation
import ModelIO
import Swinject

public protocol LightGenerator {
    init(container: Container, args: [String: GeneratorArg])
    
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLLight
    func processArgs(container: Container, args: [String: GeneratorArg])
    func copy(container: Container) -> LightGenerator
}
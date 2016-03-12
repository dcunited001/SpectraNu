//
//  SubmeshGenerator.swift
//  
//
//  Created by David Conner on 3/11/16.
//
//

import Metal
import ModelIO
import simd
import Swinject

public protocol SubmeshGenerator {
    init(container: Container, args: [String: GeneratorArg])
    
    func generate(container: Container, args: [String: GeneratorArg]) -> MDLSubmesh
    func processArgs(container: Container, args: [String: GeneratorArg])
    func copy(container: Container) -> SubmeshGenerator
}

// TODO: random_balanced_graph_submesh_gen
// - is this the right default submesh gen?
// - or should i go with triangulate submesh gen?
// - or perhaps 2D/3D delauney submesh gen


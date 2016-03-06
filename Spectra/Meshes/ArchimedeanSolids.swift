//
//  ArchimedeanSolids.swift
//  
//
//  Created by David Conner on 3/3/16.
//
//

import simd
import Swinject
import Metal
import ModelIO

// https://en.wikipedia.org/wiki/Archimedean_solid
// - truncated tetrahedron
// - cuboctahedron (rhombitetratetrahedron)
// - truncated cube
// - truncated octahedron (truncated tetratetrahedron)
// - rhombicuboctahedron
// - truncated cuboctahedron
// - snub cube (snub cuboctahedron)
// - icosidodecahedron
// - truncated dodecahedron
// - truncated icosahedron
// - rhombicosidodecahedron (small rhombicosidodecahedron)
// - truncated icosidodecahedron (great rhombicosidodecahedron)
// - snub dodecahedron (snub icosidodecahedron)

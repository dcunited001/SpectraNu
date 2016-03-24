//
//  SpectraEnumDefs.swift
//  SpectraOSX
//
//  Created by David Conner on 2/22/16.
//  Copyright © 2016 Spectra. All rights reserved.
//

import Foundation
import Metal
import ModelIO

class SpectraEnumDefs {

    static let mdlVertexFormat = [
        "Invalid": MDLVertexFormat.Invalid.rawValue,
        "PackedBit": MDLVertexFormat.PackedBit.rawValue,
        "UCharBits": MDLVertexFormat.UCharBits.rawValue,
        "CharBits": MDLVertexFormat.CharBits.rawValue,
        "UCharNormalizedBits": MDLVertexFormat.UCharNormalizedBits.rawValue,
        "CharNormalizedBits": MDLVertexFormat.CharNormalizedBits.rawValue,
        "UShortBits": MDLVertexFormat.UShortBits.rawValue,
        "ShortBits": MDLVertexFormat.ShortBits.rawValue,
        "UShortNormalizedBits": MDLVertexFormat.UShortNormalizedBits.rawValue,
        "ShortNormalizedBits": MDLVertexFormat.ShortNormalizedBits.rawValue,
        "UIntBits": MDLVertexFormat.UIntBits.rawValue,
        "IntBits": MDLVertexFormat.IntBits.rawValue,
        "HalfBits": MDLVertexFormat.HalfBits.rawValue,
        "FloatBits": MDLVertexFormat.FloatBits.rawValue,
        "UChar": MDLVertexFormat.UChar.rawValue,
        "UChar2": MDLVertexFormat.UChar2.rawValue,
        "UChar3": MDLVertexFormat.UChar3.rawValue,
        "UChar4": MDLVertexFormat.UChar4.rawValue,
        "Char": MDLVertexFormat.Char.rawValue,
        "Char2": MDLVertexFormat.Char2.rawValue,
        "Char3": MDLVertexFormat.Char3.rawValue,
        "Char4": MDLVertexFormat.Char4.rawValue,
        "UCharNormalized": MDLVertexFormat.UCharNormalized.rawValue,
        "UChar2Normalized": MDLVertexFormat.UChar2Normalized.rawValue,
        "UChar3Normalized": MDLVertexFormat.UChar3Normalized.rawValue,
        "UChar4Normalized": MDLVertexFormat.UChar4Normalized.rawValue,
        "CharNormalized": MDLVertexFormat.CharNormalized.rawValue,
        "Char2Normalized": MDLVertexFormat.Char2Normalized.rawValue,
        "Char3Normalized": MDLVertexFormat.Char3Normalized.rawValue,
        "Char4Normalized": MDLVertexFormat.Char4Normalized.rawValue,
        "UShort": MDLVertexFormat.UShort.rawValue,
        "UShort2": MDLVertexFormat.UShort2.rawValue,
        "UShort3": MDLVertexFormat.UShort3.rawValue,
        "UShort4": MDLVertexFormat.UShort4.rawValue,
        "Short": MDLVertexFormat.Short.rawValue,
        "Short2": MDLVertexFormat.Short2.rawValue,
        "Short3": MDLVertexFormat.Short3.rawValue,
        "Short4": MDLVertexFormat.Short4.rawValue,
        "UShortNormalized": MDLVertexFormat.UShortNormalized.rawValue,
        "UShort2Normalized": MDLVertexFormat.UShort2Normalized.rawValue,
        "UShort3Normalized": MDLVertexFormat.UShort3Normalized.rawValue,
        "UShort4Normalized": MDLVertexFormat.UShort4Normalized.rawValue,
        "ShortNormalized": MDLVertexFormat.ShortNormalized.rawValue,
        "Short2Normalized": MDLVertexFormat.Short2Normalized.rawValue,
        "Short3Normalized": MDLVertexFormat.Short3Normalized.rawValue,
        "Short4Normalized": MDLVertexFormat.Short4Normalized.rawValue,
        "UInt": MDLVertexFormat.UInt.rawValue,
        "UInt2": MDLVertexFormat.UInt2.rawValue,
        "UInt3": MDLVertexFormat.UInt3.rawValue,
        "UInt4": MDLVertexFormat.UInt4.rawValue,
        "Int": MDLVertexFormat.Int.rawValue,
        "Int2": MDLVertexFormat.Int2.rawValue,
        "Int3": MDLVertexFormat.Int3.rawValue,
        "Int4": MDLVertexFormat.Int4.rawValue,
        "Half": MDLVertexFormat.Half.rawValue,
        "Half2": MDLVertexFormat.Half2.rawValue,
        "Half3": MDLVertexFormat.Half3.rawValue,
        "Half4": MDLVertexFormat.Half4.rawValue,
        "Float": MDLVertexFormat.Float.rawValue,
        "Float2": MDLVertexFormat.Float2.rawValue,
        "Float3": MDLVertexFormat.Float3.rawValue,
        "Float4": MDLVertexFormat.Float4.rawValue,
        "Int1010102Normalized": MDLVertexFormat.Int1010102Normalized.rawValue,
        "UInt1010102Normalized": MDLVertexFormat.UInt1010102Normalized.rawValue]
    
    static let mdlMaterialSemantic = [
        "BaseColor": MDLMaterialSemantic.BaseColor.rawValue,
        "Subsurface": MDLMaterialSemantic.Subsurface.rawValue,
        "Metallic": MDLMaterialSemantic.Metallic.rawValue,
        "Specular": MDLMaterialSemantic.Specular.rawValue,
        "SpecularExponent": MDLMaterialSemantic.SpecularExponent.rawValue,
        "SpecularTint": MDLMaterialSemantic.SpecularTint.rawValue,
        "Roughness": MDLMaterialSemantic.Roughness.rawValue,
        "Anisotropic": MDLMaterialSemantic.Anisotropic.rawValue,
        "AnisotropicRotation": MDLMaterialSemantic.AnisotropicRotation.rawValue,
        "Sheen": MDLMaterialSemantic.Sheen.rawValue,
        "SheenTint": MDLMaterialSemantic.SheenTint.rawValue,
        "Clearcoat": MDLMaterialSemantic.Clearcoat.rawValue,
        "ClearcoatGloss": MDLMaterialSemantic.ClearcoatGloss.rawValue,
        "Emission": MDLMaterialSemantic.Emission.rawValue,
        "Bump": MDLMaterialSemantic.Bump.rawValue,
        "Opacity": MDLMaterialSemantic.Opacity.rawValue,
        "InterfaceIndexOfRefraction": MDLMaterialSemantic.InterfaceIndexOfRefraction.rawValue,
        "MaterialIndexOfRefraction": MDLMaterialSemantic.MaterialIndexOfRefraction.rawValue,
        "ObjectSpaceNormal": MDLMaterialSemantic.ObjectSpaceNormal.rawValue,
        "TangentSpaceNormal": MDLMaterialSemantic.TangentSpaceNormal.rawValue,
        "Displacement": MDLMaterialSemantic.Displacement.rawValue,
        "DisplacementScale": MDLMaterialSemantic.DisplacementScale.rawValue,
        "AmbientOcclusion": MDLMaterialSemantic.AmbientOcclusion.rawValue,
        "AmbientOcclusionScale": MDLMaterialSemantic.AmbientOcclusionScale.rawValue,
        "None": MDLMaterialSemantic.None.rawValue,
        "UserDefined": MDLMaterialSemantic.UserDefined.rawValue
    ]
    
    static let mdlMaterialPropertyType = [
        "None": MDLMaterialPropertyType.None.rawValue,
        "String": MDLMaterialPropertyType.String.rawValue,
        "URL": MDLMaterialPropertyType.URL.rawValue,
        "Texture": MDLMaterialPropertyType.Texture.rawValue,
        "Color": MDLMaterialPropertyType.Color.rawValue,
        "Float": MDLMaterialPropertyType.Float.rawValue,
        "Float2": MDLMaterialPropertyType.Float2.rawValue,
        "Float3": MDLMaterialPropertyType.Float3.rawValue,
        "Float4": MDLMaterialPropertyType.Float4.rawValue,
        "Matrix44": MDLMaterialPropertyType.Matrix44.rawValue
    ]
    
    static let mdlMaterialTextureWrapMode = [
        "Clamp": MDLMaterialTextureWrapMode.Clamp.rawValue,
        "Repeat": MDLMaterialTextureWrapMode.Repeat.rawValue,
        "Mirror": MDLMaterialTextureWrapMode.Mirror.rawValue
    ]
    
    static let mdlMaterialTextureFilterMode = [
        "Nearest": MDLMaterialTextureFilterMode.Nearest.rawValue,
        "Linear": MDLMaterialTextureFilterMode.Linear.rawValue
    ]
    
    static let mdlMaterialMipMapFilterMode = [
        "Nearest": MDLMaterialMipMapFilterMode.Nearest.rawValue,
        "Linear": MDLMaterialMipMapFilterMode.Linear.rawValue
    ]
    
    static let mdlMeshBufferType = [
        "Vertex": MDLMeshBufferType.Vertex.rawValue,
        "Index": MDLMeshBufferType.Index.rawValue
    ]
    
    static let mdlGeometryType = [
        "TypePoints": UInt(MDLGeometryType.TypePoints.rawValue),
        "TypeLines": UInt(MDLGeometryType.TypeLines.rawValue),
        "TypeTriangles": UInt(MDLGeometryType.TypeTriangles.rawValue),
        "TypeTriangleStrips": UInt(MDLGeometryType.TypeTriangleStrips.rawValue),
        "TypeQuads": UInt(MDLGeometryType.TypeQuads.rawValue),
        "TypeVariableTopology": UInt(MDLGeometryType.TypeVariableTopology.rawValue)
    ]
    
    static let mdlIndexBitDepth = [
        "Invalid": MDLIndexBitDepth.Invalid.rawValue,
        "UInt8": MDLIndexBitDepth.UInt8.rawValue,
        "UInt16": MDLIndexBitDepth.UInt16.rawValue,
        "UInt32": MDLIndexBitDepth.UInt32.rawValue
    ]
    
    static let mdlLightType = [
        "Unknown": MDLLightType.Unknown.rawValue,
        "Ambient": MDLLightType.Ambient.rawValue,
        "Directional": MDLLightType.Directional.rawValue,
        "Spot": MDLLightType.Spot.rawValue,
        "Point": MDLLightType.Point.rawValue,
        "Linear": MDLLightType.Linear.rawValue,
        "DiscArea": MDLLightType.DiscArea.rawValue,
        "RectangularArea": MDLLightType.RectangularArea.rawValue,
        "SuperElliptical": MDLLightType.SuperElliptical.rawValue,
        "Photometric": MDLLightType.Photometric.rawValue,
        "Probe": MDLLightType.Probe.rawValue,
        "Environment": MDLLightType.Environment.rawValue
    ]
}

class MetalEnumDefs {
    static let mtlVertexStepFunction = [
        "Constant": MTLVertexStepFunction.Constant.rawValue,
        "PerVertex": MTLVertexStepFunction.PerVertex.rawValue,
        "PerInstance": MTLVertexStepFunction.PerInstance.rawValue
    ]
    
    static let mtlCompareFunction = [
        "Never": MTLCompareFunction.Never.rawValue,
        "Less": MTLCompareFunction.Less.rawValue,
        "Equal": MTLCompareFunction.Equal.rawValue,
        "LessEqual": MTLCompareFunction.LessEqual.rawValue,
        "Greater": MTLCompareFunction.Greater.rawValue,
        "NotEqual": MTLCompareFunction.NotEqual.rawValue,
        "GreaterEqual": MTLCompareFunction.GreaterEqual.rawValue,
        "Always": MTLCompareFunction.Always.rawValue
    ]
    
    static let mtlStencilOperation = [
        "Keep": MTLStencilOperation.Keep.rawValue,
        "Zero": MTLStencilOperation.Zero.rawValue,
        "Replace": MTLStencilOperation.Replace.rawValue,
        "IncrementClamp": MTLStencilOperation.IncrementClamp.rawValue,
        "DecrementClamp": MTLStencilOperation.DecrementClamp.rawValue,
        "Invert": MTLStencilOperation.Invert.rawValue,
        "IncrementWrap": MTLStencilOperation.IncrementWrap.rawValue,
        "DecrementWrap": MTLStencilOperation.DecrementWrap.rawValue
    ]
    
    static let mtlVertexFormat = [
        "Invalid": MTLVertexFormat.Invalid.rawValue,
        "UChar2": MTLVertexFormat.UChar2.rawValue,
        "UChar3": MTLVertexFormat.UChar3.rawValue,
        "UChar4": MTLVertexFormat.UChar4.rawValue,
        "Char2": MTLVertexFormat.Char2.rawValue,
        "Char3": MTLVertexFormat.Char3.rawValue,
        "Char4": MTLVertexFormat.Char4.rawValue,
        "UChar2Normalized": MTLVertexFormat.UChar2Normalized.rawValue,
        "UChar3Normalized": MTLVertexFormat.UChar3Normalized.rawValue,
        "UChar4Normalized": MTLVertexFormat.UChar4Normalized.rawValue,
        "Char2Normalized": MTLVertexFormat.Char2Normalized.rawValue,
        "Char3Normalized": MTLVertexFormat.Char3Normalized.rawValue,
        "Char4Normalized": MTLVertexFormat.Char4Normalized.rawValue,
        "UShort2": MTLVertexFormat.UShort2.rawValue,
        "UShort3": MTLVertexFormat.UShort3.rawValue,
        "UShort4": MTLVertexFormat.UShort4.rawValue,
        "Short2": MTLVertexFormat.Short2.rawValue,
        "Short3": MTLVertexFormat.Short3.rawValue,
        "Short4": MTLVertexFormat.Short4.rawValue,
        "UShort2Normalized": MTLVertexFormat.UShort2Normalized.rawValue,
        "UShort3Normalized": MTLVertexFormat.UShort3Normalized.rawValue,
        "UShort4Normalized": MTLVertexFormat.UShort4Normalized.rawValue,
        "Short2Normalized": MTLVertexFormat.Short2Normalized.rawValue,
        "Short3Normalized": MTLVertexFormat.Short3Normalized.rawValue,
        "Short4Normalized": MTLVertexFormat.Short4Normalized.rawValue,
        "Half2": MTLVertexFormat.Half2.rawValue,
        "Half3": MTLVertexFormat.Half3.rawValue,
        "Half4": MTLVertexFormat.Half4.rawValue,
        "Float": MTLVertexFormat.Float.rawValue,
        "Float2": MTLVertexFormat.Float2.rawValue,
        "Float3": MTLVertexFormat.Float3.rawValue,
        "Float4": MTLVertexFormat.Float4.rawValue,
        "Int": MTLVertexFormat.Int.rawValue,
        "Int2": MTLVertexFormat.Int2.rawValue,
        "Int3": MTLVertexFormat.Int3.rawValue,
        "Int4": MTLVertexFormat.Int4.rawValue,
        "UInt": MTLVertexFormat.UInt.rawValue,
        "UInt2": MTLVertexFormat.UInt2.rawValue,
        "UInt3": MTLVertexFormat.UInt3.rawValue,
        "UInt4": MTLVertexFormat.UInt4.rawValue,
        "Int1010102Normalized": MTLVertexFormat.Int1010102Normalized.rawValue,
        "UInt1010102Normalized": MTLVertexFormat.UInt1010102Normalized.rawValue
    ]
    
    static let mtlBlendFactor = [
        "Zero": MTLBlendFactor.Zero.rawValue,
        "One": MTLBlendFactor.One.rawValue,
        "SourceColor": MTLBlendFactor.SourceColor.rawValue,
        "OneMinusSourceColor": MTLBlendFactor.OneMinusSourceColor.rawValue,
        "SourceAlpha": MTLBlendFactor.SourceAlpha.rawValue,
        "OneMinusSourceAlpha": MTLBlendFactor.OneMinusSourceAlpha.rawValue,
        "DestinationColor": MTLBlendFactor.DestinationColor.rawValue,
        "OneMinusDestinationColor": MTLBlendFactor.OneMinusDestinationColor.rawValue,
        "DestinationAlpha": MTLBlendFactor.DestinationAlpha.rawValue,
        "OneMinusDestinationAlpha": MTLBlendFactor.OneMinusDestinationAlpha.rawValue,
        "SourceAlphaSaturated": MTLBlendFactor.SourceAlphaSaturated.rawValue,
        "BlendColor": MTLBlendFactor.BlendColor.rawValue,
        "OneMinusBlendColor": MTLBlendFactor.OneMinusBlendColor.rawValue,
        "BlendAlpha": MTLBlendFactor.BlendAlpha.rawValue,
        "OneMinusBlendAlpha": MTLBlendFactor.OneMinusBlendAlpha.rawValue
    ]
    
    static let mtlBlendOperation = [
        "Add": MTLBlendOperation.Add.rawValue,
        "Subtract": MTLBlendOperation.Subtract.rawValue,
        "ReverseSubtract": MTLBlendOperation.ReverseSubtract.rawValue,
        "Min": MTLBlendOperation.Min.rawValue,
        "Max": MTLBlendOperation.Max.rawValue
    ]
    
    static let mtlLoadAction = [
        "DontCare": MTLLoadAction.DontCare.rawValue,
        "Load": MTLLoadAction.Load.rawValue,
        "Clear": MTLLoadAction.Clear.rawValue
    ]
    
    static let mtlStoreAction = [
        "DontCare": MTLStoreAction.DontCare.rawValue,
        "Store": MTLStoreAction.Store.rawValue,
        "MultisampleResolve": MTLStoreAction.MultisampleResolve.rawValue
    ]
    
    // Only available on specific versions of iOS
    static let mtlMultisampleDepthResolveFilter: [String: UInt] = [
        // TODO: how to access this enum's values?
        "Sample0": 0,
        "Min": 1,
        "Max": 2
    ]
    
    static let mtlSamplerMinMagFilter = [
        "Nearest": MTLSamplerMinMagFilter.Nearest.rawValue,
        "Linear": MTLSamplerMinMagFilter.Linear.rawValue
    ]
    
    static let mtlSamplerMipFilter = [
        "NotMipmapped": MTLSamplerMipFilter.NotMipmapped.rawValue,
        "Nearest": MTLSamplerMipFilter.Nearest.rawValue,
        "Linear": MTLSamplerMipFilter.Linear.rawValue
    ]
    
    static let mtlSamplerAddressMode = [
        "ClampToEdge": MTLSamplerAddressMode.ClampToEdge.rawValue,
        "MirrorClampToEdge": MTLSamplerAddressMode.MirrorClampToEdge.rawValue,
        "Repeat": MTLSamplerAddressMode.Repeat.rawValue,
        "MirrorRepeat": MTLSamplerAddressMode.MirrorRepeat.rawValue,
        "ClampToZero": MTLSamplerAddressMode.ClampToZero.rawValue
    ]
    
    static let mtlTextureType = [
        "Type1D": MTLTextureType.Type1D.rawValue,
        "Type1DArray": MTLTextureType.Type1DArray.rawValue,
        "Type2D": MTLTextureType.Type2D.rawValue,
        "Type2DArray": MTLTextureType.Type2DArray.rawValue,
        "Type2DMultisample": MTLTextureType.Type2DMultisample.rawValue,
        "TypeCube": MTLTextureType.TypeCube.rawValue,
        "TypeCubeArray": MTLTextureType.TypeCubeArray.rawValue,
        "Type3D": MTLTextureType.Type3D.rawValue
    ]
    
    static let mtlCpuCacheMode = [
        "DefaultCache": MTLCPUCacheMode.DefaultCache.rawValue,
        "WriteCombined": MTLCPUCacheMode.WriteCombined.rawValue
    ]
    
    static let mtlStorageMode = [
        
        "Shared": MTLStorageMode.Shared.rawValue,
        "Managed": MTLStorageMode.Managed.rawValue,
        "Private": MTLStorageMode.Private.rawValue
    ]
    
    static let mtlPurgeableState = [
        "KeepCurrent": MTLPurgeableState.KeepCurrent.rawValue,
        "NonVolatile": MTLPurgeableState.NonVolatile.rawValue,
        "Volatile": MTLPurgeableState.Volatile.rawValue,
        "Empty": MTLPurgeableState.Empty.rawValue
    ]
    
    static let mtlPixelFormat = [
        "Invalid": MTLPixelFormat.Invalid.rawValue,
        "A8Unorm": MTLPixelFormat.A8Unorm.rawValue,
        "R8Unorm": MTLPixelFormat.R8Unorm.rawValue,
        "R8Snorm": MTLPixelFormat.R8Snorm.rawValue,
        "R8Uint": MTLPixelFormat.R8Uint.rawValue,
        "R8Sint": MTLPixelFormat.R8Sint.rawValue,
        "R16Unorm": MTLPixelFormat.R16Unorm.rawValue,
        "R16Snorm": MTLPixelFormat.R16Snorm.rawValue,
        "R16Uint": MTLPixelFormat.R16Uint.rawValue,
        "R16Sint": MTLPixelFormat.R16Sint.rawValue,
        "R16Float": MTLPixelFormat.R16Float.rawValue,
        "RG8Unorm": MTLPixelFormat.RG8Unorm.rawValue,
        "RG8Snorm": MTLPixelFormat.RG8Snorm.rawValue,
        "RG8Uint": MTLPixelFormat.RG8Uint.rawValue,
        "RG8Sint": MTLPixelFormat.RG8Sint.rawValue,
        "R32Uint": MTLPixelFormat.R32Uint.rawValue,
        "R32Sint": MTLPixelFormat.R32Sint.rawValue,
        "R32Float": MTLPixelFormat.R32Float.rawValue,
        "RG16Unorm": MTLPixelFormat.RG16Unorm.rawValue,
        "RG16Snorm": MTLPixelFormat.RG16Snorm.rawValue,
        "RG16Uint": MTLPixelFormat.RG16Uint.rawValue,
        "RG16Sint": MTLPixelFormat.RG16Sint.rawValue,
        "RG16Float": MTLPixelFormat.RG16Float.rawValue,
        "RGBA8Unorm": MTLPixelFormat.RGBA8Unorm.rawValue,
        "RGBA8Unorm_sRGB": MTLPixelFormat.RGBA8Unorm_sRGB.rawValue,
        "RGBA8Snorm": MTLPixelFormat.RGBA8Snorm.rawValue,
        "RGBA8Uint": MTLPixelFormat.RGBA8Uint.rawValue,
        "RGBA8Sint": MTLPixelFormat.RGBA8Sint.rawValue,
        "BGRA8Unorm": MTLPixelFormat.BGRA8Unorm.rawValue,
        "BGRA8Unorm_sRGB": MTLPixelFormat.BGRA8Unorm_sRGB.rawValue,
        "RGB10A2Unorm": MTLPixelFormat.RGB10A2Unorm.rawValue,
        "RGB10A2Uint": MTLPixelFormat.RGB10A2Uint.rawValue,
        "RG11B10Float": MTLPixelFormat.RG11B10Float.rawValue,
        "RGB9E5Float": MTLPixelFormat.RGB9E5Float.rawValue,
        "RG32Uint": MTLPixelFormat.RG32Uint.rawValue,
        "RG32Sint": MTLPixelFormat.RG32Sint.rawValue,
        "RG32Float": MTLPixelFormat.RG32Float.rawValue,
        "RGBA16Unorm": MTLPixelFormat.RGBA16Unorm.rawValue,
        "RGBA16Snorm": MTLPixelFormat.RGBA16Snorm.rawValue,
        "RGBA16Uint": MTLPixelFormat.RGBA16Uint.rawValue,
        "RGBA16Sint": MTLPixelFormat.RGBA16Sint.rawValue,
        "RGBA16Float": MTLPixelFormat.RGBA16Float.rawValue,
        "RGBA32Uint": MTLPixelFormat.RGBA32Uint.rawValue,
        "RGBA32Sint": MTLPixelFormat.RGBA32Sint.rawValue,
        "RGBA32Float": MTLPixelFormat.RGBA32Float.rawValue,
        "BC1_RGBA": MTLPixelFormat.BC1_RGBA.rawValue,
        "BC1_RGBA_sRGB": MTLPixelFormat.BC1_RGBA_sRGB.rawValue,
        "BC2_RGBA": MTLPixelFormat.BC2_RGBA.rawValue,
        "BC2_RGBA_sRGB": MTLPixelFormat.BC2_RGBA_sRGB.rawValue,
        "BC3_RGBA": MTLPixelFormat.BC3_RGBA.rawValue,
        "BC3_RGBA_sRGB": MTLPixelFormat.BC3_RGBA_sRGB.rawValue,
        "BC4_RUnorm": MTLPixelFormat.BC4_RUnorm.rawValue,
        "BC4_RSnorm": MTLPixelFormat.BC4_RSnorm.rawValue,
        "BC5_RGUnorm": MTLPixelFormat.BC5_RGUnorm.rawValue,
        "BC5_RGSnorm": MTLPixelFormat.BC5_RGSnorm.rawValue,
        "BC6H_RGBFloat": MTLPixelFormat.BC6H_RGBFloat.rawValue,
        "BC6H_RGBUfloat": MTLPixelFormat.BC6H_RGBUfloat.rawValue,
        "BC7_RGBAUnorm": MTLPixelFormat.BC7_RGBAUnorm.rawValue,
        "BC7_RGBAUnorm_sRGB": MTLPixelFormat.BC7_RGBAUnorm_sRGB.rawValue,
        "GBGR422": MTLPixelFormat.GBGR422.rawValue,
        "BGRG422": MTLPixelFormat.BGRG422.rawValue,
        "Depth32Float": MTLPixelFormat.Depth32Float.rawValue,
        "Stencil8": MTLPixelFormat.Stencil8.rawValue,
        "Depth24Unorm_Stencil8": MTLPixelFormat.Depth24Unorm_Stencil8.rawValue,
        "Depth32Float_Stencil8": MTLPixelFormat.Depth32Float_Stencil8.rawValue
    ]
    
    // NOTE: values for an OptionSetType
    static let mtlResourceOptions = [
        "CPUModeDefaultCache": MTLResourceOptions.CPUCacheModeDefaultCache.rawValue,
        "CPUCacheModeWriteCombined": MTLResourceOptions.CPUCacheModeWriteCombined.rawValue,
        
        "StorageModeShared": MTLResourceOptions.StorageModeShared.rawValue,
        "StorageModeManaged": MTLResourceOptions.StorageModeManaged.rawValue,
        "StorageModePrivate": MTLResourceOptions.StorageModePrivate.rawValue
    ]
    
    // NOTE: values for an OptionSetType
    static let mtlTextureUsage = [
        "Unknown": MTLTextureUsage.Unknown.rawValue,
        "ShaderRead": MTLTextureUsage.ShaderRead.rawValue,
        "ShaderWrite": MTLTextureUsage.ShaderWrite.rawValue,
        "RenderTarget": MTLTextureUsage.RenderTarget.rawValue,
        "PixelFormatView": MTLTextureUsage.PixelFormatView.rawValue
    ]
    
    //
    
    static let mtlPrimitiveType = [
        "Point": MTLPrimitiveType.Point.rawValue,
        "Line": MTLPrimitiveType.Line.rawValue,
        "LineStrip": MTLPrimitiveType.LineStrip.rawValue,
        "Triangle": MTLPrimitiveType.Triangle.rawValue,
        "TriangleStrip": MTLPrimitiveType.TriangleStrip.rawValue
    ]
    
    static let mtlIndexType = [
        "UInt16": MTLIndexType.UInt16.rawValue,
        "UInt32": MTLIndexType.UInt32.rawValue
    ]
    
    static let mtlVisibilityResultMode = [
        "Disabled": MTLVisibilityResultMode.Disabled.rawValue,
        "Boolean": MTLVisibilityResultMode.Boolean.rawValue,
        "Counting": MTLVisibilityResultMode.Counting.rawValue
    ]
    
    static let mtlCullMode = [
        "None": MTLCullMode.None.rawValue,
        "Front": MTLCullMode.Front.rawValue,
        "Back": MTLCullMode.Back.rawValue
    ]
    
    static let mtlWinding = [
        "Clockwise": MTLWinding.Clockwise.rawValue,
        "CounterClockwise": MTLWinding.CounterClockwise.rawValue
    ]
    
    static let mtlDepthClipMode = [
        "Clamp": MTLDepthClipMode.Clamp.rawValue,
        "Clip": MTLDepthClipMode.Clip.rawValue
    ]
    
    static let mtlTriangleFillMode = [
        "Fill": MTLTriangleFillMode.Fill.rawValue,
        "Lines": MTLTriangleFillMode.Lines.rawValue
    ]
    
    static let mtlDataType = [
        "None": MTLDataType.None.rawValue,
        
        "Struct": MTLDataType.Struct.rawValue,
        "Array": MTLDataType.Array.rawValue,
        "Float": MTLDataType.Float.rawValue,
        
        "Float2": MTLDataType.Float2.rawValue,
        "Float3": MTLDataType.Float3.rawValue,
        "Float4": MTLDataType.Float4.rawValue,
        
        "Float2x2": MTLDataType.Float2x2.rawValue,
        "Float2x3": MTLDataType.Float2x3.rawValue,
        "Float2x4": MTLDataType.Float2x4.rawValue,
        
        "Float3x2": MTLDataType.Float3x2.rawValue,
        "Float3x3": MTLDataType.Float3x3.rawValue,
        "Float3x4": MTLDataType.Float3x4.rawValue,
        
        "Float4x2": MTLDataType.Float4x2.rawValue,
        "Float4x3": MTLDataType.Float4x3.rawValue,
        "Float4x4": MTLDataType.Float4x4.rawValue,
        "Half": MTLDataType.Half.rawValue,
        "Half2": MTLDataType.Half2.rawValue,
        "Half3": MTLDataType.Half3.rawValue,
        "Half4": MTLDataType.Half4.rawValue,
        
        "Half2x2": MTLDataType.Half2x2.rawValue,
        "Half2x3": MTLDataType.Half2x3.rawValue,
        "Half2x4": MTLDataType.Half2x4.rawValue,
        
        "Half3x2": MTLDataType.Half3x2.rawValue,
        "Half3x3": MTLDataType.Half3x3.rawValue,
        "Half3x4": MTLDataType.Half3x4.rawValue,
        
        "Half4x2": MTLDataType.Half4x2.rawValue,
        "Half4x3": MTLDataType.Half4x3.rawValue,
        "Half4x4": MTLDataType.Half4x4.rawValue,
        
        "Int": MTLDataType.Int.rawValue,
        "Int2": MTLDataType.Int2.rawValue,
        "Int3": MTLDataType.Int3.rawValue,
        "Int4": MTLDataType.Int4.rawValue,
        
        "UInt": MTLDataType.UInt.rawValue,
        "UInt2": MTLDataType.UInt2.rawValue,
        "UInt3": MTLDataType.UInt3.rawValue,
        "UInt4": MTLDataType.UInt4.rawValue,
        
        "Short": MTLDataType.Short.rawValue,
        "Short2": MTLDataType.Short2.rawValue,
        "Short3": MTLDataType.Short3.rawValue,
        "Short4": MTLDataType.Short4.rawValue,
        
        "UShort": MTLDataType.UShort.rawValue,
        "UShort2": MTLDataType.UShort2.rawValue,
        "UShort3": MTLDataType.UShort3.rawValue,
        "UShort4": MTLDataType.UShort4.rawValue,
        
        "Char": MTLDataType.Char.rawValue,
        "Char2": MTLDataType.Char2.rawValue,
        "Char3": MTLDataType.Char3.rawValue,
        "Char4": MTLDataType.Char4.rawValue,
        
        "UChar": MTLDataType.UChar.rawValue,
        "UChar2": MTLDataType.UChar2.rawValue,
        "UChar3": MTLDataType.UChar3.rawValue,
        "UChar4": MTLDataType.UChar4.rawValue,
        
        "Bool": MTLDataType.Bool.rawValue,
        "Bool2": MTLDataType.Bool2.rawValue,
        "Bool3": MTLDataType.Bool3.rawValue,
        "Bool4": MTLDataType.Bool4.rawValue
    ]
    
    static let mtlArgumentType = [
        "Buffer": MTLArgumentType.Buffer.rawValue,
        "ThreadgroupMemory": MTLArgumentType.ThreadgroupMemory.rawValue,
        "Texture": MTLArgumentType.Texture.rawValue,
        "Sampler": MTLArgumentType.Sampler.rawValue
    ]
    
    static let mtlArgumentAccess = [
        "ReadOnly": MTLArgumentAccess.ReadOnly.rawValue,
        "ReadWrite": MTLArgumentAccess.ReadWrite.rawValue,
        "WriteOnly": MTLArgumentAccess.WriteOnly.rawValue
    ]
    
    // option set type
    static let mtlBlitOption = [
        "None": MTLBlitOption.None.rawValue,
        "DepthFromDepthStencil": MTLBlitOption.DepthFromDepthStencil.rawValue,
        "StencilFromDepthStencil": MTLBlitOption.StencilFromDepthStencil.rawValue
    ]
    
    static let mtlBufferStatus = [
        "NotEnqueued": MTLCommandBufferStatus.NotEnqueued.rawValue,
        "Enqueued": MTLCommandBufferStatus.Enqueued.rawValue,
        "Committed": MTLCommandBufferStatus.Committed.rawValue,
        "Scheduled": MTLCommandBufferStatus.Scheduled.rawValue,
        "Completed": MTLCommandBufferStatus.Completed.rawValue,
        "Error": MTLCommandBufferStatus.Error.rawValue
    ]
    
    static let mtlCommandBufferError = [
        "None": MTLCommandBufferError.None.rawValue,
        "Internal": MTLCommandBufferError.Internal.rawValue,
        "Timeout": MTLCommandBufferError.Timeout.rawValue,
        "PageFault": MTLCommandBufferError.PageFault.rawValue,
        "Blacklisted": MTLCommandBufferError.Blacklisted.rawValue,
        "NotPermitted": MTLCommandBufferError.NotPermitted.rawValue,
        "OutOfMemory": MTLCommandBufferError.OutOfMemory.rawValue,
        "InvalidResource": MTLCommandBufferError.InvalidResource.rawValue
    ]
    
    static let mtlFeatureSet = [
        "OSX_GPUFamily1_v1": MTLFeatureSet.OSX_GPUFamily1_v1.rawValue
    ]
    
    static let mtlPipelineOption = [
        "None": MTLPipelineOption.None.rawValue,
        "ArgumentInfo": MTLPipelineOption.ArgumentInfo.rawValue,
        "BufferTypeInfo": MTLPipelineOption.BufferTypeInfo.rawValue
    ]
    
    static let mtlFunctionType = [
        "Vertex": MTLFunctionType.Vertex.rawValue,
        "Fragment": MTLFunctionType.Fragment.rawValue,
        "Kernel": MTLFunctionType.Kernel.rawValue
    ]
    
    static let mtlLibraryError = [
        "Unsupported": MTLLibraryError.Unsupported.rawValue,
        "Internal": MTLLibraryError.Internal.rawValue,
        "CompileFailure": MTLLibraryError.CompileFailure.rawValue,
        "CompileWarning": MTLLibraryError.CompileWarning.rawValue
    ]
    
    static let mtlRenderPipelineError = [
        "Internal": MTLRenderPipelineError.Internal.rawValue,
        "Unsupported": MTLRenderPipelineError.Unsupported.rawValue,
        "InvalidInput": MTLRenderPipelineError.InvalidInput.rawValue
    ]
    
    static let mtlPrimitiveTopologyClass = [
        "Unspecified": MTLPrimitiveTopologyClass.Unspecified.rawValue,
        "Point": MTLPrimitiveTopologyClass.Point.rawValue,
        "Line": MTLPrimitiveTopologyClass.Line.rawValue,
        "Triangle": MTLPrimitiveTopologyClass.Triangle.rawValue
    ]
}
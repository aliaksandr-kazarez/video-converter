//
//  reduceVideoQuality.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/6/24.
//

import AVFoundation

func allSupportedPresets(for asset: AVURLAsset, outputFileType: AVFileType?) async -> [String] {
    let presets = await withTaskGroup(of: (String,Bool).self) { group -> [String] in
        let allPresets = AVAssetExportSession.allExportPresets()
        for preset in allPresets {
            group.addTask {
                (preset, await AVAssetExportSession.compatibility(ofExportPreset: preset, with: asset, outputFileType: outputFileType))
            }
        }
        var result: [String] = []
        for await (preset, isAvailable) in group {
            if isAvailable {
                result.append(preset)
            }
        }
        return result
    }
    
    return presets
}

func reduceVideoQuality(of asset: AVURLAsset, quality: String) async throws -> URL {
    // TODO: Check if export preset is compatible
    let outputURL = URL.documentsDirectory.appending(path: "out.mp4")
    
    if FileManager.default.fileExists(atPath: outputURL.path()) {
        try FileManager.default.removeItem(at: outputURL)
    }
    
    guard let exportSession = AVAssetExportSession(asset: asset, presetName: quality) else {
        throw NSError(
            domain: "ExportError", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Export session could not be created."])
    }

    do {
        try await exportSession.export(to: outputURL, as: .mp4)
    } catch {
        throw NSError(
            domain: "ExportError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export session fails to export."])
    }
    
    return outputURL
}

//
//  Movie+metadata.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/11/24.
//

import AVFoundation

struct VideoProperties {
    let resolution: CGSize?
    let fps: Double?
    let metadata: [String: Any]
    
    static var empty: VideoProperties {
        return VideoProperties(resolution: nil, fps: nil, metadata: [:])
    }
}

extension AVURLAsset {
    func getVideoProperties() async -> VideoProperties {
        // Get resolution and frame rate
        let (resolution, fps): (CGSize?, Double?) = await {
            guard
                let track = try? await self.loadTracks(withMediaType: .video).first,
                let (naturalSize, preferredTransform, nominalFrameRate) = try? await track.load(
                    .naturalSize,
                    .preferredTransform,
                    .nominalFrameRate
                )
            else { return (nil, nil) }

            let size = naturalSize.applying(preferredTransform)
            return (CGSize(width: abs(size.width), height: abs(size.height)), Double(nominalFrameRate))
        }()

        // Get metadata
        let metadata: [String: Any] = await {
            guard let metadata = try? await self.loadMetadata(for: .quickTimeMetadata) else { return [:] }
            var result: [String: Any] = [:]
            for item in metadata {
                let value = try? await item.load(.value)
                guard let key = item.commonKey?.rawValue, let value else { continue }
                result[key] = value
            }
            return result
        }()

        return VideoProperties(resolution: resolution, fps: fps, metadata: metadata)
    }

}

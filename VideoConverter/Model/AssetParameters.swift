//
//  Quality.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation
import Foundation

struct Resolution {
    let width: Double
    let height: Double
}

struct AssetParameters {
    let resolution: Resolution
    let fps: Float
    let bitrate: Float
    let codec: AVVideoCodecType
    let fileSize: Int
    let duration: CMTime
}

extension AVURLAsset {
    func parameters() async -> AssetParameters? {
        // Load video tracks
        guard let videoTrack = try? await self.loadTracks(withMediaType: .video).first else {
            return nil  // No video track available
        }

        do {
            // Load track properties asynchronously
            let (naturalSize, nominalFrameRate, estimatedDataRate, formatDescriptions) = try await videoTrack.load(
                .naturalSize,
                .nominalFrameRate,
                .estimatedDataRate,
                .formatDescriptions
            )
            //            let preferredTransform = try await videoTrack.load(.preferredTransform)

            return AssetParameters(
                resolution: naturalSize.resolution,
                fps: nominalFrameRate,
                bitrate: estimatedDataRate,
                codec: formatDescriptions.videoCodecType ?? .h264,
                fileSize: self.fileSize,
                duration: try await self.load(.duration)
            )
        } catch {
            print("Failed to load video parameters: \(error)")
            return nil
        }
    }
}

extension CGSize {
    var resolution: Resolution {
        return Resolution(width: width, height: height)
    }
}

extension [CMFormatDescription] {
    var videoCodecType: AVVideoCodecType? {
        guard let formatDescription = self.first else { return nil }
        let mediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription)
        return mediaSubType.codecType
    }
}

extension AVURLAsset {
    var fileSize: Int {
        guard let resourceValues = try? self.url.resourceValues(forKeys: [.fileSizeKey]),
              let fileSize = resourceValues.fileSize
        else { return 0 }
        return fileSize
    }
}


extension FourCharCode {
    /// Converts a FourCharCode into `AVVideoCodecType` if possible
    fileprivate var codecType: AVVideoCodecType {
        let codecString = String(
            format: "%c%c%c%c",
            (self >> 24) & 0xff,
            (self >> 16) & 0xff,
            (self >> 8) & 0xff,
            self & 0xff)
        return AVVideoCodecType(rawValue: codecString)
    }
}

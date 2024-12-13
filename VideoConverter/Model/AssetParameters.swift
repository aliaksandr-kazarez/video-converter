//
//  Quality.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import Foundation
import AVFoundation

struct Resolution {
    let width: Int
    let height: Int
}

struct AssetParameters {
    let resolution: Resolution
    let fps: Double
    let bitrate: Int
    let codec: AVVideoCodecType
    let fileSize: Int
}

extension AVURLAsset {
    /// Returns the `Quality` of the video asset, or `nil` if no video track is available.
    var quality: AssetParameters? {
        guard let videoTrack = self.tracks(withMediaType: .video).first else {
            return nil // No video track available
        }
        
        // Extract resolution
        let size = Resolution(width: Int(videoTrack.naturalSize.width), height: Int(videoTrack.naturalSize.height))
        
        // Extract FPS
        let fps = videoTrack.nominalFrameRate
        
        // Extract bitrate (estimatedDataRate is in bits per second)
        let bitrate = Int(videoTrack.estimatedDataRate)
        
        // Extract codec type (using format descriptions)
        let codecType: AVVideoCodecType
        if let formatDescriptions = videoTrack.formatDescriptions as? [CMFormatDescription],
           let formatDescription = formatDescriptions.first,
           let codec = CMFormatDescriptionGetMediaSubType(formatDescription).codecType {
            codecType = codec
        } else {
            codecType = .h264 // Default to H.264 if codec can't be determined
        }
        
        let fileSize: Int
        do {
            let resourceValues = try self.url.resourceValues(forKeys: [.fileSizeKey])
            fileSize = resourceValues.fileSize ?? 0
        } catch {
            fileSize = 0 // Default to 0 if file size can't be determined
        }
        
        return AssetParameters(
            resolution: size,
            fps: Double(fps),
            bitrate: bitrate,
            codec: codecType,
            fileSize: fileSize
        )
    }
}

fileprivate extension FourCharCode {
    /// Converts a FourCharCode into `AVVideoCodecType` if possible
    var codecType: AVVideoCodecType? {
        let codecString = String(format: "%c%c%c%c",
                                 (self >> 24) & 0xff,
                                 (self >> 16) & 0xff,
                                 (self >> 8) & 0xff,
                                 self & 0xff)
        return AVVideoCodecType(rawValue: codecString)
    }
}

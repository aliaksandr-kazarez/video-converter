//
//  Quality.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation
import Foundation

struct AssetParameters {
    let resolution: Resolution
    let frameRate: Float
    let bitrate: Float

    let codec: AVVideoCodecType

    let fileSize: Int
    let duration: CMTime
}

struct VideoQuality {
    let resolution: Resolution
    let frameRate: Float
    let bitrate: Float
}

extension VideoQuality {
    enum Quality: Float {
        case low = 1_000_000
        case medium = 5_000_000
        case high = 10_000_000

        func bitrate(
            resolution: Resolution, frameRate: Float, baseResolution: Resolution = .p1080, baseFrameRate: Float = 30
        )
            -> Float
        {
            let resolutionFactor =
                (resolution.width * resolution.height) / (baseResolution.width * baseResolution.height)
            let frameRateFactor = Double(frameRate) / Double(baseFrameRate)
            return self.rawValue / Float((resolutionFactor * frameRateFactor))

        }
    }

    init(resolution: Resolution, frameRate: Float, quality: Quality) {
        self.init(
            resolution: resolution,
            frameRate: frameRate,
            bitrate: quality.bitrate(resolution: resolution, frameRate: frameRate)
        )
    }

    static let low = VideoQuality(resolution: .p360, frameRate: 30, quality: .high)
    static let medium = VideoQuality(resolution: .p720, frameRate: 30, quality: .high)
    static let high = VideoQuality(resolution: .p1080, frameRate: 60, quality: .high)
}

extension AVURLAsset {
    func videoQualtiy() async -> VideoQuality? {
        guard let videoTrack = try? await self.loadTracks(withMediaType: .video).first else {
            return nil  // No video track available
        }

        do {
            let (naturalSize, nominalFrameRate, estimatedDataRate) = try await videoTrack.load(
                .naturalSize,
                .nominalFrameRate,
                .estimatedDataRate
            )

            return VideoQuality(
                resolution: naturalSize.resolution,
                frameRate: nominalFrameRate,
                bitrate: estimatedDataRate

            )
        } catch {
            print("Failed to load video parameters: \(error)")
            return nil
        }

    }

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
                frameRate: nominalFrameRate,
                bitrate: estimatedDataRate,
                codec: formatDescriptions.videoCodecType ?? .h264,
                fileSize: self.fileSize,
                duration: await self.videoDuration
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

func fileSizeInBytes(duration: CMTime, quality: VideoQuality) -> Int {
    let durationInSeconds = CMTimeGetSeconds(duration)
    let bits = durationInSeconds * Double(quality.bitrate)
    return Int(bits / 8)  // Convert to bytes
}

extension AVURLAsset {
    var videoDuration: CMTime {
        get async {
            return (try? await self.load(.duration)) ?? .zero
        }
    }
    var fileName: String {
        guard let resourceValues = try? self.url.resourceValues(forKeys: [.nameKey]),
            let name = resourceValues.name
        else { return self.url.lastPathComponent }
        return name
    }

    var fileSize: Int {
        guard let resourceValues = try? self.url.resourceValues(forKeys: [.fileSizeKey]),
            let fileSize = resourceValues.fileSize
        else { return 0 }
        return fileSize
    }
}

extension FourCharCode {
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

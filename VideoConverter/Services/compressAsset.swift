//
//  CompressAsset.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation

extension VideoQuality {
    func withAspectRatio(_ aspectRatio: Double) -> VideoQuality {
        let resolution = Resolution(height: self.resolution.height, aspectRatio: aspectRatio)
        return VideoQuality(resolution: resolution, frameRate: self.frameRate, bitrate: self.bitrate)
    }
}

func compress(asset: AVURLAsset, with quality: VideoQuality) async throws -> URL {
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mp4")
    if FileManager.default.fileExists(atPath: outputURL.path) {
        try FileManager.default.removeItem(at: outputURL)
    }
    
    guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "No video track found", code: -1, userInfo: nil)
    }
    
    // Set up AVAssetReader
    guard let assetReader = try? AVAssetReader(asset: asset) else {
        throw NSError(domain: "Failed to create AVAssetReader", code: -1, userInfo: nil)
    }
    
    let readerOutputSettings: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    
    let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
    assetReader.add(readerOutput)
    
    // Set up AVAssetWriter
    guard let assetWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
        throw NSError(domain: "Failed to create AVAssetWriter", code: -1, userInfo: nil)
    }
    
    let naturalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
    let width = abs(naturalSize.width)
    let height = abs(naturalSize.height)
    
    let writerInput = AVAssetWriterInput.from(quality: quality.withAspectRatio(width/height))
    assetWriter.add(writerInput)
    
    // Start reading and writing
    assetReader.startReading()
    assetWriter.startWriting()
    assetWriter.startSession(atSourceTime: .zero)
    
    
    return try await withCheckedThrowingContinuation { continuation in
        let dispatchQueue = DispatchQueue(label: "videoConversionQueue")
        writerInput.requestMediaDataWhenReady(on: dispatchQueue) {
            while writerInput.isReadyForMoreMediaData {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(sampleBuffer)
                } else {
                    writerInput.markAsFinished()
                    assetWriter.finishWriting {
                        if assetWriter.status == .completed {
                            continuation.resume(returning: outputURL)
                        } else {
                            continuation.resume(throwing: assetWriter.error ?? NSError(domain: "Unknown error", code: -1, userInfo: nil))
                        }
                    }
                    break
                }
            }
        }
    }
}

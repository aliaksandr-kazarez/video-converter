//
//  CompressAsset.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation

func compress(asset: AVURLAsset) async throws -> URL {
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("compressed.mp4")
    if FileManager.default.fileExists(atPath: outputURL.path) {
        try FileManager.default.removeItem(at: outputURL)
    }
    
    guard let videoTrack = asset.tracks(withMediaType: .video).first else {
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
    
    let videoOutputSettings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(videoTrack.naturalSize.width),
        AVVideoHeightKey: Int(videoTrack.naturalSize.height),
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 5_000_000, // 5 Mbps
        ]
    ]
    
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoOutputSettings)
    writerInput.expectsMediaDataInRealTime = false
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

// Example Usage
//let inputURL = URL(fileURLWithPath: "/path/to/input/video.mp4")
//let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("converted_video.mp4")
//
//compress(asset: inputURL, outputURL: outputURL) { result in
//    switch result {
//    case .success(let url):
//        print("Video converted successfully: \(url)")
//    case .failure(let error):
//        print("Failed to convert video: \(error)")
//    }
//}

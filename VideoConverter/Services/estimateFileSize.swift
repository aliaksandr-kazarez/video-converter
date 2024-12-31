//
//  estimateFileSize.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/29/24.
//
import AVFoundation

func estimateFileSize(videoQuality: VideoQuality, duration: CMTime) -> Double {
    // File size in bytes
    let fileSizeInBits = videoQuality.bitrate * Float(duration.seconds)
    return Double(fileSizeInBits) / 8 // Convert bits to bytes
}

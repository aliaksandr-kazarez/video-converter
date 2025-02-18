//
//  Asset.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation
import AVKit
import SwiftUI

struct AssetView: View {
    let asset: AVURLAsset
//    @State var preview: any View?
    @State var parameters: AssetParameters?

    var body: some View {
            VStack {
                Spacer()
//                if preview == nil { ProgressView() }
                Spacer()
                TableView(title: asset.fileName, data: parameters?.tableViewData ?? [])
                    .panel(background: .regularMaterial)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                VideoPreview(videoAsset: asset)
                    .ignoresSafeArea()
//                preview?.resizable().aspectRatio(contentMode: .fill).ignoresSafeArea()
            )
            .background(Color.gray)
        .task {
            async let tasks = (asset.toImage(), asset.parameters())
            let (preview, parameters) = await tasks
            
            try? await Task.sleep(for: .seconds(5))
            
            withAnimation {
//                self.preview = preview
                self.parameters = parameters
            }
        }
    }
}

extension VideoQuality {
    fileprivate var tableViewData: [(String, String)] {
        [
            ("Resolution", resolutionString),
            ("Frame Rate", frameRateString),
            ("Bitrate", bitrateString),
//            ("Codec", codecString),
//            ("Size", fileSizeString),
//            ("Duration", durationString)
        ]
    }
//    fileprivate var durationString: String {
//        let totalSeconds = Int(CMTimeGetSeconds(self.duration))
//        guard totalSeconds >= 0 else { return "00:00" }
//        
//        let hours = totalSeconds / 3600
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//        
//        if hours > 0 {
//            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//        } else {
//            return String(format: "%02d:%02d", minutes, seconds)
//        }
//    }
//    fileprivate var fileSizeString: String {
//        let byteFormatter = ByteCountFormatter()
//        byteFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
//        byteFormatter.countStyle = .file
//        return byteFormatter.string(fromByteCount: Int64(fileSize))
//    }
    fileprivate var resolutionString: String {
        "\(resolution.width)x\(resolution.height)"
    }
    fileprivate var frameRateString: String {
        "\(String(format: "%.2f", frameRate)) FPS"
    }
    fileprivate var bitrateString: String {
        if bitrate >= 1_000_000 {
            return "\(bitrate / 1_000_000) Mbps"
        } else if bitrate >= 1_000 {
            return "\(bitrate / 1_000) Kbps"
        } else {
            return "\(bitrate) bps"
        }
    }
//    fileprivate var codecString: String {
//        switch codec {
//        case .h264:
//            return "H.264"
//        case .hevc:
//            return "HEVC (H.265)"
//        case .jpeg:
//            return "JPEG"
//        case .proRes4444:
//            return "ProRes 4444"
//        case .proRes422:
//            return "ProRes 422"
//        default:
//            return codec.rawValue
//        }
//    }
}

extension AssetParameters {
    fileprivate var tableViewData: [(String, String)] {
        [
            ("Resolution", resolutionString),
            ("Frame Rate", frameRateString),
            ("Bitrate", bitrateString),
            ("Codec", codecString),
            ("Size", fileSizeString),
            ("Duration", durationString)
        ]
    }
    fileprivate var durationString: String {
        let totalSeconds = Int(CMTimeGetSeconds(self.duration))
        guard totalSeconds >= 0 else { return "00:00" }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    fileprivate var fileSizeString: String {
        let byteFormatter = ByteCountFormatter()
        byteFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteFormatter.countStyle = .file
        return byteFormatter.string(fromByteCount: Int64(fileSize))
    }
    fileprivate var resolutionString: String {
        "\(resolution.width)x\(resolution.height)"
    }
    fileprivate var frameRateString: String {
        "\(String(format: "%.2f", frameRate)) FPS"
    }
    fileprivate var bitrateString: String {
        if bitrate >= 1_000_000 {
            return "\(bitrate / 1_000_000) Mbps"
        } else if bitrate >= 1_000 {
            return "\(bitrate / 1_000) Kbps"
        } else {
            return "\(bitrate) bps"
        }
    }
    fileprivate var codecString: String {
        switch codec {
        case .h264:
            return "H.264"
        case .hevc:
            return "HEVC (H.265)"
        case .jpeg:
            return "JPEG"
        case .proRes4444:
            return "ProRes 4444"
        case .proRes422:
            return "ProRes 422"
        default:
            return codec.rawValue
        }
    }
}

#Preview {
    let asset = AVURLAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    Group {
        AssetView(asset: asset)
    }
//    .frame(width: 200, height: 500)
}

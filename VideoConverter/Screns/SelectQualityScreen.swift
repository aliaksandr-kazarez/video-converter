//
//  TransferFileView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/18/25.
//

import SwiftUI
import PhotosUI

public struct SelectQualityScreen: View {
    @State var asset: AVURLAsset
    @State private var selectedQuality: VideoQuality = .medium
    @State private var estimatedFileSize: Double = 0
    @EnvironmentObject private var router: Router

    public var body: some View {
        VStack {
            AssetView(asset: asset)
            Picker("Choose Preset", selection: $selectedQuality) {
                ForEach([("Low", VideoQuality.low), ("Medium", VideoQuality.medium), ("High", VideoQuality.high)], id: \.0) {
                    (name, quality) in
                        Text(name).tag(quality)
                }
            }
            Label("New Size: \(fileSizeString(size: estimatedFileSize))", systemImage: "file.badge.plus")
            Button("Compress") {
                router.navigate(to: .exportVideoScreen(assetToExport: asset, selectedExportQuality: selectedQuality))
            }
        }
        .onChange(of: selectedQuality) {
            Task {
                guard let duration = try? await asset.load(.duration) else { /* Error Retrieving duration for asset */ return }
                estimatedFileSize = estimateFileSize(videoQuality: selectedQuality, duration: duration)
            }
        }
    }
}

func fileSizeString(size: Double) -> String {
    let byteFormatter = ByteCountFormatter()
    byteFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    byteFormatter.countStyle = .file
    return byteFormatter.string(fromByteCount: Int64(size))
}


#Preview {
    let asset = AVURLAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    Group {
        SelectQualityScreen(asset: asset)
            .environmentObject(Router())
    }
}

//
//  TransferFileView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/18/25.
//

import SwiftUI
import PhotosUI

public struct TransferFileView: View {
    public let itemToTransfer: PhotosPickerItem
    
    @State private var asset: AVURLAsset?
    @State private var isLoading: Bool = false
    @State private var selectedQuality: VideoQuality = .medium
    @State private var estimatedFileSize: Double = 0
    @EnvironmentObject private var router: Router

    public var body: some View {
        VStack {
            if let asset {
                AssetView(asset: asset)
                Picker("Choose Preset", selection: $selectedQuality) {
                    ForEach([("Low", VideoQuality.low), ("Medium", VideoQuality.medium), ("High", VideoQuality.high)], id: \.0) {
                        (name, quality) in
                            Text(name).tag(quality)
                    }
                }
                Label("New Size: \(fileSizeString(size: estimatedFileSize))", systemImage: "file.badge.plus")
                ShareLink("Convert and Share", items: [ExportableMovie(asset: asset, quality: selectedQuality)]) {
                    movie in
                    SharePreview(
                        "Export",
                        image: Image(systemName: "figure.wave.circle.fill"),
                        icon: Image(systemName: "figure.walk.diamond")
                    )
                }
            } else if isLoading {
                ProgressView()
            } else {
                Text("No selected Video")
            }
            Button("Import Video") {
                router.navigate(to: .videoPicker)
            }
        }
        .onAppear {
            Task {
                isLoading = true
                self.asset = nil

                defer {
                    isLoading = false
                }

                guard let asset = try? await itemToTransfer.loadTransferable(type: TransferableAVURLAsset.self)?.asset else { return }
                
                withAnimation(.easeOut) {
                    self.asset = asset
                }
            }
        }
        .onChange(of: selectedQuality) {
            guard let duration = asset?.duration else { return }
            estimatedFileSize = estimateFileSize(videoQuality: selectedQuality, duration: duration)
        }
    }
}

func fileSizeString(size: Double) -> String {
    let byteFormatter = ByteCountFormatter()
    byteFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    byteFormatter.countStyle = .file
    return byteFormatter.string(fromByteCount: Int64(size))
}

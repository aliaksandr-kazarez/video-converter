//
//  VideoPickerView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/6/24.
//

import AVFoundation
import AVKit
import Photos
import PhotosUI
import SwiftUI

struct ExportableMovie: Transferable {
    let asset: AVURLAsset
    let quality: VideoQuality

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .video) { movie in
            guard let compressedVideoURL = try? await compress(asset: movie.asset, with: movie.quality) else {
                throw NSError(domain: "ExportableMovie", code: -1)
            }
            return SentTransferredFile(compressedVideoURL)
        }
    }
}

struct MainScreen: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var preview: Image?
    @State private var asset: AVURLAsset?
    @State private var isLoading: Bool = false
    @State private var selectedQuality: VideoQuality = .medium
    @State private var qualitites: [(String, VideoQuality)] = [("Low", .low), ("Medium", .medium), ("High", .high)]
    @State private var exporting = false
    @State private var estimatedFileSize: Double = 0

    @Namespace private var animationNamespace
    
    private var isButtonInToolbar: Bool {
        asset != nil
    }

    @ViewBuilder private var photosPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .videos, photoLibrary: .shared()) {
            Label("Select Video", systemImage: "square.and.arrow.down")
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 3.0)))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if let asset {
                    AssetView(asset: asset)
                    Picker("Choose Preset", selection: $selectedQuality) {
                        ForEach(qualitites, id: \.0) { (name, qualtiy) in
                            Text(name).tag(qualtiy)
                        }
                    }
                    Label("New Size: \(fileSizeString(size: estimatedFileSize))", systemImage: "file.badge.plus")
                    ShareLink("Convert and Share", items: [ExportableMovie(asset: asset, quality: selectedQuality)])
                    {
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
                    //                Text("No selected Video")
                }
                photosPicker
                    .buttonStyle(.borderedProminent)
                    .hidden(isButtonInToolbar)
                    .matchedGeometryEffect(
                        id: "button",
                        in: animationNamespace,
                        properties: .frame,
                        isSource: !isButtonInToolbar
                    )
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    photosPicker
                        .buttonStyle(.borderless)
                        .hidden(!isButtonInToolbar)
                        .matchedGeometryEffect(
                            id: "button",
                            in: animationNamespace,
                            properties: .position,
                            isSource: isButtonInToolbar
                        )
                    Spacer()
                }
            }
        }
        .onChange(of: selectedQuality) {
            guard let duration = asset?.duration else { return }
            estimatedFileSize = estimateFileSize(videoQuality: selectedQuality, duration: duration);
            
        }
        .onChange(of: selectedItem) {
            Task {
                isLoading = true
                self.asset = nil

                defer {
                    isLoading = false
                }

                guard let selectedItem,
                    let asset = try? await selectedItem.loadTransferable(type: TransferableAVURLAsset.self)?.asset
                else { return }
                
                withAnimation(.easeOut) {
                    self.asset = asset
                }
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
    MainScreen()
}

struct VideoFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.movie, .quickTimeMovie] }  // Specify content types for reading
    static var writableContentTypes: [UTType] { [.movie, .video, .quickTimeMovie] }  // Explicitly declare writable content types

    private var fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    init(configuration: ReadConfiguration) throws {
        throw NSError(
            domain: "VideoFileDocument", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reading not supported"])
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: fileURL)
    }
}

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
    let preset: String
    let asset: AVURLAsset

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .video) { movie in
            guard let exportingURL = try? await reduceVideoQuality(of: movie.asset, quality: movie.preset) else {
                throw NSError(domain: "ExportableMovie", code: -1)
            }
            return SentTransferredFile(exportingURL)
        }
    }
}

struct MainScreen: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var preview: Image?
    @State private var asset: AVURLAsset?
    @State private var isLoading: Bool = false
    @State private var properties: VideoProperties = .empty
    @State private var presetForExport: String?
    @State private var supportedPresets: [String] = []
    @State private var exporting = false

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
                    Picker("Choose Preset", selection: $presetForExport) {
                        Text("Noting Selected").tag(nil as String?)
                        ForEach(supportedPresets, id: \.self) { preset in
                            Text(preset).tag(preset)
                        }
                    }
                    if let presetForExport {
                        ShareLink("Convert and Share", items: [ExportableMovie(preset: presetForExport, asset: asset)])
                        {
                            movie in
                            SharePreview(
                                "Export",
                                image: Image(systemName: "figure.wave.circle.fill"),
                                icon: Image(systemName: "figure.walk.diamond")
                            )
                        }
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
        .onChange(of: selectedItem) {
            Task {
                isLoading = true
                self.properties = .empty
                self.asset = nil
                self.preview = nil

                defer {
                    isLoading = false
                }

                guard let selectedItem,
                    let asset = try await selectedItem.loadTransferable(type: TransferableAVURLAsset.self)?.asset
                else { return }

                self.preview = await asset.toImage()
                self.properties = await asset.getVideoProperties()
                self.supportedPresets = await allSupportedPresets(for: asset, outputFileType: .mp4)
                withAnimation(.easeOut) {
                    self.asset = asset
                }
            }
        }
    }
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

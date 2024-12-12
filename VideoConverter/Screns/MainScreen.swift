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

struct MainScreen: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var preview: Image?
    @State private var asset: AVURLAsset?
    @State private var isLoading: Bool = false
    @State private var properties: VideoProperties = .empty
    @State private var exportSelection: String = ""
    @State private var supportedPresets: [String] = []
    @State private var exporting = false
    @State private var exportingURL: URL?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let preview {
                preview
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding()
            } else {
                Text("No preview available")
                    .foregroundColor(.gray)
            }
            if asset != nil {
                Picker("Choose Preset", selection: $exportSelection) {
                    ForEach(supportedPresets, id: \.self) { preset in
                        Text(preset)
                    }
                }
                if let exportingURL { ShareLink(item: exportingURL) }
                Button {
                    Task {
                        guard let asset else { return }
                        exportingURL = try? await reduceVideoQuality(of: asset, quality: exportSelection)
                    }
                } label: {
                    Text("Export Video")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            VideoPropertiesView(videoProperties: properties)
            PhotosPicker(selection: $selectedItem, matching: .videos, photoLibrary: .shared()) {
                Text("Select Video")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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

                self.preview = await asset.toThumbnailImage()
                self.properties = await asset.getVideoProperties()
                self.supportedPresets = await allSupportedPresets(for: asset, outputFileType: .mp4)
                self.asset = asset
            }
        }
    }
}

struct VideoFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.movie, .quickTimeMovie] } // Specify content types for reading
    static var writableContentTypes: [UTType] { [.movie, .video, .quickTimeMovie] } // Explicitly declare writable content types
    
    private var fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    init(configuration: ReadConfiguration) throws {
        throw NSError(domain: "VideoFileDocument", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reading not supported"])
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: fileURL)
    }
}

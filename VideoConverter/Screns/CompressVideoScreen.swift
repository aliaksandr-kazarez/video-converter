//
//  ExportFileView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 2/18/25.
//

import SwiftUI
import PhotosUI

public struct CompressVideoScreen: View {
    let asset: AVURLAsset
    let quality: VideoQuality
    
    @State private var isLoading: Bool = false
    @State private var selectedQuality: VideoQuality = .medium
    @State private var estimatedFileSize: Double = 0
    @EnvironmentObject private var router: Router
    
    public var body: some View {
        VStack {
            ProgressView("Compressing Video...")
        }
        .onAppear {
            Task {
                isLoading = true
                
                defer {
                    isLoading = false
                }
                
                guard let compressedVideoURL = try? await compress(asset: asset, with: quality) else {
                    throw NSError(domain: "ExportableMovie", code: -1)
                }
                
                withAnimation(.easeOut) {
                    router
                        .navigate(
                            to: .finishedExportingVideoScreen(exportedVideoAsset: AVURLAsset(url: compressedVideoURL))
                        )
                }
            }
        }
    }
}

#Preview {
    let asset = AVURLAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    CompressVideoScreen(asset: asset, quality: .medium)
        .environmentObject(Router())
}

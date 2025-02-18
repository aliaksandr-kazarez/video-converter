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
            ProgressView()
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
                    router.navigate(to: .selectQualityScreen(asset))
                }
            }
        }
    }
}

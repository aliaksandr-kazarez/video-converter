//
//  PHUIVideoPickerView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/11/24.
//

import AVFoundation
import CoreTransferable
import PhotosUI
import SwiftUI

struct VideoAssetPicker<Label: View>: View {
    @Binding var asset: AVURLAsset?
    @State private var selectedItem: PhotosPickerItem? = nil
    @ViewBuilder let label: @Sendable () -> Label

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .videos, photoLibrary: .shared(), label: label)
            .onChange(of: selectedItem) {
                Task {
                    guard let selectedItem,
                        let asset = try await selectedItem.loadTransferable(type: TransferableAVURLAsset.self)
                    else { return }

                    self.asset = asset.asset
                }
            }
    }
}

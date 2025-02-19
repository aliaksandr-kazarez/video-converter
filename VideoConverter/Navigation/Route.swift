//
//  Route.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//

import SwiftUI
import PhotosUI

enum Route {
    case videoPickerScreen
    // TODO: getRid of photosPickerItem in favor of some abstraction
    case transferScreen(selectedVideo: PhotosPickerItem)
    case exportQualityScreen(asset: AVURLAsset)
    case exportVideoScreen(assetToExport: AVURLAsset, selectedExportQuality: VideoQuality)
    case finishedExportingVideoScreen(exportedVideoAsset: AVURLAsset)
}

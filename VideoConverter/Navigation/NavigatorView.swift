//
//  NavigationView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//

import SwiftUI

struct NavigatorView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        NavigationStack {
            switch router.currentRoute {
            case .videoPickerScreen:
                VideoPickerScreen()
            case .transferScreen(let selectedItem):
                TransferVideoScreen(videoPickerItem: selectedItem)
            case .exportQualityScreen(let asset):
                SelectQualityScreen(asset: asset)
            case .exportVideoScreen(assetToExport: let assetToExport, selectedExportQuality: let selectedExportQuality):
                CompressVideoScreen(asset: assetToExport, quality: selectedExportQuality)
            case .finishedExportingVideoScreen(exportedVideoAsset: let exportedVideoAsset):
                CompressVideoResultScreen(asset: exportedVideoAsset)
            }
        }
    }
}

#Preview {
    NavigatorView()
        .environmentObject(Router(.videoPickerScreen))
}


struct VideoProcessingScreen: View {
    var body: some View {
        Text("Video Processing")
    }
}

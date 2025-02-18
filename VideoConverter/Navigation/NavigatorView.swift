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
            case .home:
                HomeScreen()
            case .videoPicker:
                VideoPickerScreen()
            case .downloadPickedVideo(let selectedItem):
                TransferFileView(itemToTransfer: selectedItem)
            case .videoProcessing:
                VideoProcessingScreen()
            case .selectQualityScreen(let asset):
                SelectQualityScreen(asset: asset)
            }
        }
    }
}

#Preview {
    NavigatorView()
        .environmentObject(Router(.videoPicker))
}


struct HomeScreen: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        Text("Home")
        Button("Go to Video Picker") {
            router.navigate(to: .videoPicker)
        }
        
    }
}

struct VideoProcessingScreen: View {
    var body: some View {
        Text("Video Processing")
    }
}

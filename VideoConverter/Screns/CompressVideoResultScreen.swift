//
//  ExportFinishView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 2/18/25.
//

import SwiftUI
import AVKit

struct CompressVideoResultScreen: View {
    @State var asset: AVURLAsset
    @EnvironmentObject private var router: Router

    var body: some View {
        VStack {
            Spacer()
            ShareLink("Share Video", items: [asset.url])
            Button(action: {
                router.navigate(to: .videoPickerScreen)
            }) {
                Text("Select Another Video")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            VideoPreview(videoAsset: asset)
                .ignoresSafeArea()

        }
    }
}

#Preview {
    let asset = AVURLAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    CompressVideoResultScreen(asset: asset)
        .environmentObject(Router())
}


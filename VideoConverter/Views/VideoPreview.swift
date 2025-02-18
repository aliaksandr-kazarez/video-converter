//
//  VideoBackgroundView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//


import SwiftUI
import AVKit

struct VideoPreview: UIViewControllerRepresentable {
    private let player: AVPlayer
    
    // Инициализация с URL
    init(videoURL: URL) {
        self.player = AVPlayer(url: videoURL)
        self.player.isMuted = true
        self.player.actionAtItemEnd = .none
    }
    
    // Инициализация с AVAsset
    init(videoAsset: AVAsset) {
        let item = AVPlayerItem(asset: videoAsset)
        self.player = AVPlayer(playerItem: item)
        self.player.isMuted = true
        self.player.actionAtItemEnd = .none
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        player.play()
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

#Preview {
    let asset = AVURLAsset(url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!)
    VideoPreview(videoAsset: asset)
        .ignoresSafeArea()
}

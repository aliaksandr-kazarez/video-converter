//
//  Movie+Preview.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/11/24.
//

import AVFoundation
import SwiftUICore

extension AVURLAsset {
    func toThumbnailImage() async -> Image {
        return await self.generateImage(from: self)
    }

    fileprivate func generateImage(from asset: AVURLAsset) async -> Image {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true  // Correct orientation
        
        do {
            let (image, actulTime) = try await imageGenerator.image(at: .zero)
            print("Generated video preview in \(actulTime)")
            return Image(decorative: image, scale: 1.0, orientation: .up)
        } catch {
            print("Failed to generate video preview: \(error)")
            return Image(systemName: "exclamationmark.circle")  // Placeholder for failure
        }
    }
}


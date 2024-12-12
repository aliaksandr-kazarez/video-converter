//
//  VideoPropertiesView.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/11/24.
//

import SwiftUI

struct VideoPropertiesView: View {
    let videoProperties: VideoProperties

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Video Properties")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            // Resolution
            if let resolution = videoProperties.resolution {
                HStack {
                    Text("Resolution:")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(resolution.width)) x \(Int(resolution.height))")
                        .foregroundColor(.blue)
                }
            } else {
                Text("Resolution: Unknown")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            // FPS
            HStack {
                Text("Frame Rate:")
                    .font(.headline)
                Spacer()
                Text(videoProperties.fps != nil ? "\(videoProperties.fps!, specifier: "%.2f") FPS" : "Unknown")
                    .foregroundColor(.blue)
            }

            // Metadata
            if !videoProperties.metadata.isEmpty {
                Text("Metadata:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(videoProperties.metadata.keys.sorted(), id: \.self) { key in
                        HStack(alignment: .top) {
                            Text("\(key):")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(videoProperties.metadata[key] ?? "Unknown")")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.leading, 8)
            } else {
                Text("No Metadata Available")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding()
    }
}

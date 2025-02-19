//
//  Landing.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//

import SwiftUI
import PhotosUI

struct VideoPickerScreen: View {
    @EnvironmentObject var router: Router
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker("", selection: $selectedItem, matching: .videos)
            .photosPickerStyle(.inline)
            .photosPickerDisabledCapabilities([.selectionActions])
            .onChange(of: selectedItem) {
                guard let selectedItem else { return }
                // TODO transfer transferable to application FS for processing
                router.navigate(to: .transferScreen(selectedVideo: selectedItem))
            }
//            .navigationTitle("Select Video")
    }
}



#Preview {
    VideoPickerScreen()
        .environmentObject(Router())
}

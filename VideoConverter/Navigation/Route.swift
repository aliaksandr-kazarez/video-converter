//
//  Route.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 1/17/25.
//

import SwiftUI
import PhotosUI

enum Route {
    case home
    case videoPicker
    case downloadPickedVideo(PhotosPickerItem)
    case videoProcessing
}

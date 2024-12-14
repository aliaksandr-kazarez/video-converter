//
//  Resolution.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/13/24.
//


struct Resolution {
    let width: Double
    let height: Double
}

extension Resolution {
    // should we maintain apect ratio?
    static let p360 = Resolution(width: 640, height: 360)
    static let p720 = Resolution(width: 1280, height: 720)
    static let p1080 = Resolution(width: 1920, height: 1080)
    static let p1440 = Resolution(width: 2560, height: 1440)
    static let p4K = Resolution(width: 3840, height: 2160)
}

//
//  Resolution.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/13/24.
//



struct Resolution: Hashable {
    enum ResolutionName: Double {
        case p360 = 360
        case p720 = 720
        case p1080 = 1080
        case p1440 = 1440
        case p4K = 2160
    }
    
    let height: Double
    let aspectRatio: Double
    var width: Double { height * aspectRatio }
    
    init(height: Double, aspectRatio: Double) {
        self.height = height
        self.aspectRatio = aspectRatio
    }
    
    init(width: Double, height: Double) {
        self.init(height: height, aspectRatio: width / height)
    }
    
    init (_ name: ResolutionName, aspectRatio: Double = 16/9) {
        self.init(height: name.rawValue, aspectRatio: aspectRatio)
    }
}

extension Resolution {
    // should we maintain apect ratio?
    static let p360 = Resolution(width: 640, height: 360)
    static let p720 = Resolution(width: 1280, height: 720)
    static let p1080 = Resolution(width: 1920, height: 1080)
    static let p1440 = Resolution(width: 2560, height: 1440)
    static let p4K = Resolution(width: 3840, height: 2160)
}

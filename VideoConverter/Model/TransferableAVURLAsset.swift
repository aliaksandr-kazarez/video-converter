//
//  TransferableAVURLAsset.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/11/24.
//

import CoreTransferable
import AVFoundation

struct TransferableAVURLAsset: Transferable {
    let asset: AVURLAsset
    
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { asset in
            SentTransferredFile(asset.asset.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: received.file.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            return .init(asset: AVURLAsset(url: copy))
        }
    }
}

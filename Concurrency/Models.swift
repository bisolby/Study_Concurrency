//
//  ImageMetadata.swift
//  Concurrency
//
//  Created by Heejae Kim on 2022/01/21.
//

import UIKit

struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

struct DetailedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

enum ImageDownloadError: Error {
    case badImage
    case invalidMetadata
}

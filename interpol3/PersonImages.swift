//
//  PersonImages.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

struct PersonImages: Codable {
    let embedded: EmbeddedImages

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct EmbeddedImages: Codable {
    let images: [Image]
}

struct Image: Codable {
    let pictureID: String
    let links: ImageLinks

    enum CodingKeys: String, CodingKey {
        case pictureID = "picture_id"
        case links = "_links"
    }
}

struct ImageLinks: Codable {
    let linksSelf: NoticeImage

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}

struct NoticeImage: Codable {
    let href: String
}

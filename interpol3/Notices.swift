//
//  Notices.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation


struct Notices: Codable {
    let total: Int
    let embedded: Embedded
    let links: RedNoticesLinks

    enum CodingKeys: String, CodingKey {
        case total
        case embedded = "_embedded"
        case links = "_links"
    }
}

struct Embedded: Codable {
    let notices: [Notice]
}

struct Notice: Codable {
    let dateOfBirth: String
    let nationalities: [String]?
    let entityID: String
    let forename: String?
    let name: String?
    let links: NoticeLinks

    enum CodingKeys: String, CodingKey {
        case dateOfBirth = "date_of_birth"
        case nationalities
        case entityID = "entity_id"
        case forename, name
        case links = "_links"
    }
}

struct NoticeLinks: Codable {
    let linksSelf, images: First
    let thumbnail: First?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case images, thumbnail
    }
}

struct First: Codable {
    let href: String
}

struct RedNoticesLinks: Codable {
    let linksSelf, first, last: First
    let next: First?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case first, last, next
    }
}

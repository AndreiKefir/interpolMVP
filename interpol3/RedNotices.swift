//
//  RedNotices.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

struct RedNotices: Codable {
    let total: Int
    let embedded: Embedded
    
    enum CodingKeys: String, CodingKey {
        case total
        case embedded = "_embedded"
    }
}

struct Embedded: Codable {
    let notices: [Notice]
}

struct Notice: Codable {
    let dateOfBirth: String
    let nationalities: [String]?
    let entityID, forename, name: String
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
    let linkSelf, images, thumbnail: First
    
    enum CodingKeys: String, CodingKey {
        case linkSelf = "self"
        case images, thumbnail
    }
}

struct First: Codable {
    let href: String
}

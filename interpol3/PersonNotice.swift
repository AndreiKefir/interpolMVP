//
//  PersonNotice.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

struct PersonNotice: Codable {
    let arrestWarrants: [ArrestWarrant]
    let weight: Double?
    let forename: String?
    let dateOfBirth, entityID: String
    let languagesSpokenIDS, nationalities: [String]?
    let height: Double?
    let sexID: String?
    let name: String?
    let countryOfBirthID: String?
    let distinguishingMarks: String?
    let eyesColorsID, hairsID: [String]?
    let placeOfBirth: String?
    let links: Links

    enum CodingKeys: String, CodingKey {
        case arrestWarrants = "arrest_warrants"
        case weight, forename
        case dateOfBirth = "date_of_birth"
        case entityID = "entity_id"
        case languagesSpokenIDS = "languages_spoken_ids"
        case nationalities, height
        case sexID = "sex_id"
        case countryOfBirthID = "country_of_birth_id"
        case name
        case distinguishingMarks = "distinguishing_marks"
        case eyesColorsID = "eyes_colors_id"
        case hairsID = "hairs_id"
        case placeOfBirth = "place_of_birth"
        case links = "_links"
    }
}

struct ArrestWarrant: Codable {
    let issuingCountryID, charge: String?

    enum CodingKeys: String, CodingKey {
        case issuingCountryID = "issuing_country_id"
        case charge
    }
}

struct Links: Codable {
    let linksSelf, images, thumbnail: Images?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case images, thumbnail
    }
}

struct Images: Codable {
    let href: String
}

//
//  NetworkManager.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

class Network {
    static let shared = Network()
    private let session: URLSession
    var searchQuery: [URLQueryItem] = []
    
    private init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func createURL(by queries: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ws-public.interpol.int"
        components.path = "/notices/v1/red"
        components.queryItems = queries
        
        return components.url
    }
    
    func fetchImageData(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidImageUrl
        }
        guard let (data, _) = try? await session.data(from: url) else {
            throw NetworkError.invalidImageData
        }
        return data
    }

    func fetchPersonImages(from imagesLink: String) async throws -> PersonImages {
        guard let url = URL(string: imagesLink) else {
            throw NetworkError.invalidUrl
        }
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(PersonImages.self, from: data)
    }
    
    func fetchPersonData(from idString: String) async throws -> PersonNotice {
        let siteString = "https://ws-public.interpol.int/notices/v1/red/"
        let personIDString = siteString + idString
        guard let url = URL(string: personIDString) else {
            throw NetworkError.invalidUrl
        }
        let (data, response) = try await session.data(from: url)
        guard let personInfo =  try? JSONDecoder().decode(PersonNotice.self, from: data) else {
            throw NetworkError.invalidData
        }
        return personInfo
    }
    
    func fetchNoticesData(by url: URL) async throws -> Notices {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        guard let noticesInfo = try? JSONDecoder().decode(Notices.self, from: data) else {
            throw NetworkError.invalidData
        }
        return noticesInfo
    }

}

enum NetworkError: Error {
        case invalidUrl
        case invalidImageUrl
        case invalidRequest
        case invalidResponse
        case invalidData
        case invalidImageData
}
   

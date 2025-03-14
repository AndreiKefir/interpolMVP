//
//  NetworkManager.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

class Networker {
    static let shared = Networker()
    private let session: URLSession
    var searchQuery: [URLQueryItem] = []
    
    private init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func createURL(by queries: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ws-public.interpol.int"
        components.path = "/notices/v1/red"
        components.queryItems = queries
   
        let url = components.url
        print("---!!!\(url!)")
        return url ?? URL(string: "https://ws-public.interpol.int/notices/v1/red?")!
    }
    
//    func fetchImageData(by urlString: String) async throws -> Data {
//        guard let url = URL(string: urlString) else {
//            throw NetworkerError.invalidUrl
//        }
//        return try Data(contentsOf: url)
//    }
    func fetchImageData(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else {
            throw NetworkerError.invalidImageUrl
        }
        do {
            let (data, _) = try await session.data(from: url)
            return data
        } catch {
            throw NetworkerError.invalidImageData
        }
//        return try Data(contentsOf: url)
    }
     

    func getPersonImages(by imagesLink: String) async throws -> PersonImages {
        guard let url = URL(string: imagesLink) else {
            throw NetworkerError.invalidUrl
        }
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(PersonImages.self, from: data)
    }
    
    func getPerson(by idString: String) async throws -> PersonNotice {
        let personString = "https://ws-public.interpol.int/notices/v1/red/"
        let string = personString + idString
//        print("-- ! \(string)")
        guard let url = URL(string: string) else {
            throw NetworkerError.invalidUrl
        }
        do {
            let (data, response) = try await session.data(from: url)
            return try JSONDecoder().decode(PersonNotice.self, from: data)
        } catch {
//            print(" - !!! -")
            throw NetworkerError.invalidData
        }
    }
    
    func fetchNoticesData(by url: URL) async throws -> Notices {
//        guard let url = URL(string: "https://ws-public.interpol.int/notices/v1/red?resultPerPage=20") else {
//            throw NetworkError.invalidUrl
 //       }
        do {
            let (data, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
//                print("code: \(httpResponse.statusCode)")
//                print("\(url)")
            }
            return try JSONDecoder().decode(Notices.self, from: data)
        } catch {
            throw NetworkerError.invalidData
        }
    }
}

enum NetworkerError: Error {
        case invalidUrl
        case invalidImageUrl
        case invalidRequest
        case invalidResponse
        case invalidData
        case invalidImageData
}
   

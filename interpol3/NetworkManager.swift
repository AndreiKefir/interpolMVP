//
//  NetworkManager.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import Foundation

class NetworkManager {
    static var shared = NetworkManager()
    private init() { }
    
    var jsonDecoder: JSONDecoder = {
        JSONDecoder()
    }()
    
    var searchQuery: [URLQueryItem] = []
    
    func createURL(by queries: [URLQueryItem]) -> URL {
    
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ws-public.interpol.int"
        components.path = "/notices/v1/red"
        components.queryItems = queries
   
        let url = components.url
        print("---!!!\(url!)")
        return url ?? URL(string: "https://ws-public.interpol.int/notices/v1/red?forename=bob&resultPerPage=160")!
    }
    
    func getImageNow(by urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidUrl
        }
        return try Data(contentsOf: url)
    }
    

    func getPersonImages(by imagesLink: String) async throws -> PersonImages {
        guard let url = URL(string: imagesLink) else {
            throw NetworkError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try jsonDecoder.decode(PersonImages.self, from: data)
    }
    
    func getPerson(by idString: String) async throws -> PersonNotice {
        let personString = "https://ws-public.interpol.int/notices/v1/red/"
        let string = personString + idString
//        print("-- ! \(string)")
        guard let url = URL(string: string) else {
            throw NetworkError.invalidUrl
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return try jsonDecoder.decode(PersonNotice.self, from: data)
        } catch {
//            print(" - !!! -")
            throw NetworkError.invalidData
        }
    }
    
    func getNotices(by url: URL) async throws -> RedNotices {
//        guard let url = URL(string: "https://ws-public.interpol.int/notices/v1/red?resultPerPage=20") else {
//            throw NetworkError.invalidUrl
 //       }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
//                print("code: \(httpResponse.statusCode)")
//                print("\(url)")
            }
            return try jsonDecoder.decode(RedNotices.self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
}

enum NetworkError: Error {
        case invalidUrl
        case invalidRequest
        case invalidResponse
        case invalidData
}
   

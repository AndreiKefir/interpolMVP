//
//  MainPresenter.swift
//  interpolMVP
//
//  Created by Andy Kefir on 20/03/2025.
//

import Foundation

protocol MainViewProtocol: AnyObject {
    func setHeader(totalNotices: Int?)
    func updateTableView()
    func showError(_ error: Error)
}

class MainPresenter {
    weak var view: MainViewProtocol?
    
    private var notes: [Notice] = []
    private var images: [Data?] = []
    private var nextURLString: String?
    private var totalFoundedNotices: Int?
    private var isLoading = false
    private var isDataLoaded = false
    
    private let countries: Countries
    private let network: Network
    
    init(view: MainViewProtocol, countries: Countries = Countries(), network: Network = Network.shared) {
        self.view = view
        self.countries = countries
        self.network = network
    }
    
    func loadNotices() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                if isDataLoaded {
                    try await loadAdditionalNotices()
                } else {
                    try await loadInitialNotices()
                    await updateHeader(totalNotices: totalFoundedNotices)
                }
                await updateTableView()
            } catch {
                await showError(error)
            }
            self.isLoading = false
        }
    }
    
    private func loadInitialNotices() async throws {
        guard let url = network.createURL(by: network.searchQuery) else {
            throw NetworkError.invalidUrl
        }
        let result = try await loadNoticesData(url: url)
        notes = result.notices
        isDataLoaded = true
        nextURLString = result.nextURL
        await loadImages(for: result.notices)
    }
    
    private func loadAdditionalNotices() async throws {
        if let nextURLString = nextURLString, let url = URL(string: nextURLString) {
            let result = try await loadNoticesData(url: url)
            notes.append(contentsOf: result.notices)
            self.nextURLString = result.nextURL
            await loadImages(for: result.notices)
        }
    }
    
    private func loadNoticesData(url: URL) async throws -> (notices: [Notice], nextURL: String?) {
        let result = try await network.fetchNoticesData(by: url)
        totalFoundedNotices = result.total
        return (result.embedded.notices, result.links.next?.href)
    }
    
    private func loadImages(for notices: [Notice]) async {
        for notice in notices {
            let imageData = await loadImage(for: notice)
            images.append(imageData)
        }
    }
    
    private func loadImage(for notice: Notice) async -> Data? {
        guard let imageLink = notice.links.thumbnail?.href else { return nil }
        do {
            let imageData = try await network.fetchImageData(from: imageLink)
            return imageData
        } catch {
            print("Image loading error: \(error)")
            return nil
        }
    }
    
    func calculateAge(from birthDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = dateFormatter.date(from: birthDate) else { return "" }
        let components = Calendar.current.dateComponents([.year], from: date, to: Date())
        return "\(components.year ?? 0) years old"
    }
    
    func numberOfNotices() -> Int {
        return notes.count
    }
    
    func notice(at index: Int) -> Notice? {
        guard index < notes.count else { return nil }
        return notes[index]
    }
    
    func imageData(at index: Int) -> Data? {
        guard index < images.count else { return nil }
        return images[index]
    }
    
    func resetData() {
        notes.removeAll()
        images.removeAll()
        nextURLString = nil
        isDataLoaded = false
        isLoading = false
    }
    
    // MARK: - UI Updates on Main Thread using @MainActor
       @MainActor private func updateHeader(totalNotices: Int?) {
           view?.setHeader(totalNotices: totalNotices)
       }
       
       @MainActor private func updateTableView() {
           view?.updateTableView()
       }
       
       @MainActor private func showError(_ error: Error) {
           view?.showError(error)
       }
}

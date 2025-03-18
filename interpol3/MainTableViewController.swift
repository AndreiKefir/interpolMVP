//
//  MainTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class MainTableViewController: UITableViewController {
    private let myBlueColor = #colorLiteral(red: 0, green: 0.1617512107, blue: 0.4071177244, alpha: 1)
    var notes: [Notice] = []
    var numberOfNotices: Int? {
        didSet {
            createHeader()
        }
    }
    let countries = Countries()
    var nextURLString: String?
    var images: [UIImage?] = []
    var isLoading = false
    var isDataLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        createHeader()
    }
    
    func configureView() {
        title = "INTERPOL"
        navigationController?.navigationBar.barTintColor = myBlueColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchVC))
        
        let redNoticeView = UIImageView(image: UIImage(named: "redNotice"))
        redNoticeView.contentMode = .scaleAspectFit
        redNoticeView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: redNoticeView)
        NSLayoutConstraint.activate([
            redNoticeView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        let backgroundImage = UIImageView(frame: self.tableView.bounds)
        backgroundImage.image = UIImage(named: "fon2")
        backgroundImage.contentMode = .scaleAspectFill
        self.tableView.backgroundView = backgroundImage
        tableView.rowHeight = 160
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)  
        showNotices()
    }
    
    func showNotices() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                if isDataLoaded {
                    await loadAdditionalNotices()
                } else {
                    await loadInitialNotices()
                }
            } catch {
                print("error while loading notices: \(error)")
            }
            tableView.reloadData()
            isLoading = false
        }
    }
    
    private func loadInitialNotices() async {
        do {
            guard let url = Network.shared.createURL(by: Network.shared.searchQuery) else {
                throw NetworkError.invalidUrl
            }
            let result = try await loadNoticesData(url: url)
            notes = result.notices
            isDataLoaded = true
            nextURLString = result.nextURL
            
            await loadImages(for: result.notices)
        } catch {
            print("error loading initial data: \(error)")
        }
    }
    
    private func loadAdditionalNotices() async {
        do {
            if let nextURLString = nextURLString, let url = URL(string: nextURLString) {
                let result = try await loadNoticesData(url: url)
                notes.append(contentsOf: result.notices)
                self.nextURLString = result.nextURL
                await loadImages(for: result.notices)
            }
        } catch {
            print("error loading additional data: \(error)")
        }
    }
    
    private func loadNoticesData(url: URL) async throws -> (notices: [Notice], nextURL: String?) {
        let result = try await Network.shared.fetchNoticesData(by: url)
        numberOfNotices = result.total
        return (result.embedded.notices, result.links.next?.href)
    }
    
    private func loadImages(for notices: [Notice]) async {
        for note in notices {
            let image = await loadImage(for: note)
            images.append(image)
        }
    }
    
    private func loadImage(for note: Notice) async -> UIImage? {
            guard let imageLink = note.links.thumbnail?.href else { return UIImage(named: "person")! }
            do {
                guard let imageData = try await Network.shared.fetchImageData(from: imageLink) else { return UIImage(named: "person") }
                return UIImage(data: imageData)
            } catch {
                print("Image loading error: \(error)")
                return UIImage(named: "person")
            }
        }
    
    private func createHeader() {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30)
        headerLabel.backgroundColor = .clear
        headerLabel.text = if numberOfNotices != nil {
            "\(numberOfNotices ?? 0) persons found"
        } else {
            "searching..."
        }
        headerLabel.textAlignment = .center
        tableView.tableHeaderView = headerLabel
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        
        cell.textLabel?.text = "\(notes[indexPath.row].name ?? "")\n\(notes[indexPath.row].forename ?? "")"
        cell.detailTextLabel!.text = "\(calculateAge(from: notes[indexPath.row].dateOfBirth))\n\(countries.getCountryName(by: notes[indexPath.row].nationalities?.first ?? ""))"
        
        cell.imageView?.image = images[indexPath.row]
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.layer.borderColor = myBlueColor.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.contentMode = .scaleAspectFill
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = myBlueColor
        cell.detailTextLabel?.textColor = .black
        
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        cell.detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.imageView!.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            cell.imageView!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            cell.imageView!.widthAnchor.constraint(equalToConstant: 100),
            cell.imageView!.heightAnchor.constraint(equalToConstant: 120),
            cell.textLabel!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 150),
            cell.textLabel!.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30),
            cell.textLabel!.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30),
            cell.detailTextLabel!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 150),
            cell.detailTextLabel!.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30),
            cell.detailTextLabel!.topAnchor.constraint(lessThanOrEqualTo: cell.textLabel!.bottomAnchor, constant: 20),
            cell.detailTextLabel!.bottomAnchor.constraint(greaterThanOrEqualTo: cell.bottomAnchor, constant: -30)
        ])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailTableViewController
        let personIDString = notes[indexPath.row].entityID.replacingOccurrences(of: "/", with: "-")
        detailVC.personID = personIDString
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            if !isLoading && nextURLString != nil {
                print("try")
                showNotices()
            }
        }
    }
        
    @objc func openSearchVC() {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchTableViewController
        navigationController?.pushViewController(searchVC, animated: true)
        images.removeAll()
        notes.removeAll()
        nextURLString = nil
        isLoading = false
        isDataLoaded = false
    }
    
    func calculateAge(from birthDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = dateFormatter.date(from: birthDate) else { return "   " }
        let components = Calendar.current.dateComponents([.year], from: date, to: Date())
        return "\(components.year ?? 0) years old"
    }

}

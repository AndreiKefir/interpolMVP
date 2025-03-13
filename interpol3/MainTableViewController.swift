//
//  MainTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class MainTableViewController: UITableViewController {
    var notes: [Notice] = []
    var numberOfNotices: Int?
    var thumbnails: [String] = []
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "INTERPOL"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchVC))
        
        createHeader()
        tableView.rowHeight = 160
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNotices()
    }
    
    func showNotices() {
        Task {
            do {
                
                let result = try await NetworkManager.shared.getNotices(by: NetworkManager.shared.createURL(by: NetworkManager.shared.searchQuery))
                notes = result.embedded.notices
                numberOfNotices = result.total
                
                for note in notes {
                    if let link = note.links.thumbnail?.href {
                        if let photo = try await UIImage(data: NetworkManager.shared.getImageNow(by: link)) {
                            images.append(photo)
                        }
                    } else {
                        images.append(UIImage(named: "person")!)
                    }
                }
                
            } catch NetworkError.invalidUrl {
                print("??? invalid URL ???")
            } catch NetworkError.invalidData {
                print("??? invalid Data ???")
            } catch NetworkError.invalidResponse {
                print("??? invalid response ???")
            }
            tableView.reloadData()
        }
        
    }
    
    func createHeader() {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        headerLabel.backgroundColor = .yellow
        headerLabel.text = "found \(numberOfNotices ?? 0) persons"
        headerLabel.textAlignment = .center
        tableView.tableHeaderView = headerLabel
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)

        cell.backgroundColor = .systemBlue
        cell.imageView?.image = images[indexPath.row]
        cell.imageView?.layer.cornerRadius = 10
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
        cell.textLabel?.text = "\(notes[indexPath.row].name)\n\(notes[indexPath.row].forename)"
        cell.detailTextLabel!.text = calculateAge(from: notes[indexPath.row].dateOfBirth)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailTableViewController
        let personIDString = notes[indexPath.row].entityID.replacingOccurrences(of: "/", with: "-")
        detailVC.personID = personIDString
        navigationController?.pushViewController(detailVC, animated: true)
    }
        
    @objc func openSearchVC() {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchTableViewController
        navigationController?.pushViewController(searchVC, animated: true)
        thumbnails.removeAll()
        images.removeAll()
        notes.removeAll()
    }
    
    func calculateAge(from birthDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = dateFormatter.date(from: birthDate) else { return "   " }
        let components = Calendar.current.dateComponents([.year], from: date, to: Date())
        return "\(components.year ?? 0) years old"
    }

}

//
//  MainTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class MainTableViewController: UITableViewController {
    let myBlueColor = #colorLiteral(red: 0, green: 0.1617512107, blue: 0.4071177244, alpha: 1)
    var notes: [Notice] = []
    var numberOfNotices: Int?
    var nextURLString: String?
    var images: [UIImage] = []
    var isLoading = false
    var isDataLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "INTERPOL"
        
//        let backgroundImage = UIImageView(frame: self.tableView.bounds)
//        backgroundImage.image = UIImage(named: "fon")
//        backgroundImage.contentMode = .scaleAspectFill
//        self.tableView.backgroundView = backgroundImage
        
        navigationController?.navigationBar.barTintColor = myBlueColor
//        navigationController?.navigationBar.backgroundColor = myBlueColor
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.barTintColor = myBlueColor.withAlphaComponent(0.5)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchVC))
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
                print("start load")
                if nextURLString != nil {
                    if let url = URL(string: nextURLString!) {
                        let result = try await Networker.shared.fetchNoticesData(by: url)
                        let newNotes = result.embedded.notices
                        notes.append(contentsOf: newNotes)
//                        print("+++ \(notes.count)")
                        if let newNextURLString = result.links.next?.href {
                            if newNextURLString != nextURLString {
                                nextURLString = newNextURLString
                            } else {
                                nextURLString = nil
                            }
                        } else {
                            nextURLString = nil
                        }
                        for note in newNotes {
                            if let imageLink = note.links.thumbnail?.href {
                                if let imageData = try await Networker.shared.fetchImageData(from: imageLink) {
                                    if let image = UIImage(data: imageData) {
                                        images.append(image)
                                    }
                                }
                            } else {
                                images.append(UIImage(named: "person")!)
                            }
                        }
                    }
                }
                if !isDataLoaded {
                    let result = try await Networker.shared.fetchNoticesData(by: Networker.shared.createURL(by: Networker.shared.searchQuery))
                    notes = result.embedded.notices
                    numberOfNotices = result.total
                    isDataLoaded = true
                    if let nextLink = result.links.next?.href {
                        nextURLString = nextLink
                    }
                    for note in notes {
                        if let imageLink = note.links.thumbnail?.href {
                            if let imageData = try await Networker.shared.fetchImageData(from: imageLink) {
                                if let image = UIImage(data: imageData) {
                                    images.append(image)
                                }
                            }
                        } else {
                            images.append(UIImage(named: "person")!)
                        }
                    }
                }
                
            } catch NetworkerError.invalidUrl {
                print("??? invalid URL ???")
            } catch NetworkerError.invalidData {
                print("??? invalid Data ???")
            } catch NetworkerError.invalidImageData {
                print("??? invalid image Data ???")
            } catch NetworkerError.invalidResponse {
                print("??? invalid response ???")
            } catch NetworkerError.invalidImageUrl {
                print("??? invalid image URL ???")
            }
            createHeader()
            tableView.reloadData()
            isLoading = false
//            print(notes.count)
        }

    }
    
    func createHeader() {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30)
        headerLabel.backgroundColor = .clear
        headerLabel.text = "\(numberOfNotices ?? 0) persons found"
        headerLabel.textAlignment = .center
        tableView.tableHeaderView = headerLabel
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        
        let backgroundImage = UIImageView(frame: cell.bounds)
        backgroundImage.image = UIImage(named: "fon2")
        backgroundImage.contentMode = .scaleAspectFill
        tableView.backgroundView = backgroundImage
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = myBlueColor
        cell.detailTextLabel?.textColor = .black
        
        cell.imageView?.image = images[indexPath.row]
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.layer.borderColor = myBlueColor.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.contentMode = .scaleAspectFill
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

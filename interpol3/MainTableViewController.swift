//
//  MainTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class MainTableViewController: UITableViewController {
    var notes: [Notice] = []
    var thumbnails: [String] = []
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 2 commit 2
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //        self.navigationItem.rightBarButtonItem = self.editButtonItem
        //       self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(openSearchVC))
        
             tableView.rowHeight = 160
             let headerLabel = UILabel()
             headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
             headerLabel.backgroundColor = .yellow
             headerLabel.text = "some text info"
             headerLabel.textAlignment = .center
             tableView.tableHeaderView = headerLabel

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
                print("working")
                
                for note in notes {
                    thumbnails.append(note.links.thumbnail.href)
                }
                for element in thumbnails {
                    let thumbnailData = try await NetworkManager.shared.getImageNow(by: element)
                    if let image = UIImage(data: thumbnailData) {
                        images.append(image)
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)

        cell.backgroundColor = .systemBlue
        cell.imageView?.image = images[indexPath.row]
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.imageView!.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            cell.imageView!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            cell.imageView!.widthAnchor.constraint(equalToConstant: 100),
            cell.imageView!.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        cell.textLabel?.text = "\(notes[indexPath.row].name) \n \(notes[indexPath.row].forename)"
        cell.detailTextLabel?.text = "\(notes[indexPath.row].dateOfBirth)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailTableViewController
        let personIDString = notes[indexPath.row].entityID.replacingOccurrences(of: "/", with: "-")
        print(" ! \(personIDString)")
        detailVC.personID = personIDString
        navigationController?.pushViewController(detailVC, animated: true)
    }
        
    
    @objc func openSearchVC() {
        
    }
    
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

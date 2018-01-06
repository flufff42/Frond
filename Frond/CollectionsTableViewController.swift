//
//  CollectionsTableViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import MongoKitten

class CollectionsTableViewController: UITableViewController {

    var server: Server?
    var database: String = ""
    var collections = [MongoKitten.Collection]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let server = server else { return }
        MongoDB.listCollections(on: server, database: database) { (result) in
            switch result {
            case .success(let collections):
                self.collections = collections.sorted(by: { (c1, c2) -> Bool in
                    let nameKeyPath = \MongoKitten.Collection.name
                    return c1[keyPath: nameKeyPath] < c2[keyPath: nameKeyPath]
                })
                DispatchQueue.main.async {
                    self.title = "Collections"
                    self.tableView.reloadData()
                }
            case .error(let e):
                dump(e)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeConnection(_:)))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        let collection = collections[indexPath.row]
        cell.textLabel?.text = collection.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = collections[indexPath.row]

        guard let collectionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Collection") as? CollectionViewController else {
            fatalError()
        }
        collectionController.title = collection.name
        collectionController.server = server
        collectionController.database = database
        collectionController.collection = collection.name
        navigationController?.pushViewController(collectionController, animated: true)
    }

    @IBAction func closeConnection(_ sender: Any) {
        dismiss(animated: true)
    }
}

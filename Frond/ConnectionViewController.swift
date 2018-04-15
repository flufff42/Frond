//
//  ConnectionViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit

class ConnectionViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Connection"
        document?.open(completionHandler: { (success) in
            if success {
                guard let connection = self.document as? FrondDocument else { return }
                dump("Opened Frond Connection document at \(connection.fileURL)")
                if let connectionStringURL = URL(string: connection.connectionString!) {
                    self.documentNameLabel.text = "\(connectionStringURL.scheme ?? "")://\(connectionStringURL.host ?? ""):\(connectionStringURL.port ?? 0)\(connectionStringURL.path)"
                }
                MongoDB.connect(connectionString: connection.connectionString!, completion: { (result) in
                    guard case .success(let server) = result else {
                        self.appendConnectionStatus(string: "Failed to connect \(result)")
                        return
                    }
                    self.appendConnectionStatus(string: "Connected")
                    let database = connection.connectionString?.components(separatedBy: "/").last ?? ""
                    MongoDB.listCollections(on: server, database: database, completion: { (result) in
                        guard case .success(let collections) = result else {
                            self.appendConnectionStatus(string: "Failed to get collections for database \(database) \(result)")
                            return
                        }
                        DispatchQueue.main.async {
                            self.appendConnectionStatus(string: "\n Collections \(collections)")
                            let collectionsViewController = CollectionsTableViewController()
                            if let document = self.document as? FrondDocument {
                                collectionsViewController.document = document
                            }
                            collectionsViewController.server = server
                            collectionsViewController.database = database
                            self.navigationController?.pushViewController(collectionsViewController, animated: true)
                        }
                    })
                })
            } else {
                self.appendConnectionStatus(string: "Failed to open connection file")
            }
        })
    }

    func appendConnectionStatus(string: String) {
        DispatchQueue.main.async {
            self.documentNameLabel.text?.append("\n\(string)")
        }
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}

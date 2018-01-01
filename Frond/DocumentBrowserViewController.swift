//
//  DocumentBrowserViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
         browserUserInterfaceStyle = .dark
         view.tintColor = .green

        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let connectionStringAlert = UIAlertController(title: "Connection String", message: "Enter the connection string for the MongoDB instance to connect to", preferredStyle: .alert)
        connectionStringAlert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Name"
        }
        connectionStringAlert.addTextField { (connectionStringTextField) in
            connectionStringTextField.placeholder = "Connection String (mongodb://)"
        }
        connectionStringAlert.addAction(UIAlertAction(title: "Create Connection", style: .default, handler: { (action) in
            var newDocumentURL: URL? = nil

            guard
                let name = connectionStringAlert.textFields?.first?.text,
                let connectionString = connectionStringAlert.textFields?.last?.text else {
                importHandler(nil, .none)
                return
            }

            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).frondconnection")
            let document = FrondDocument(fileURL: temporaryURL)
            document.connectionString = connectionString
            document.save(to: document.fileURL, for: .forCreating, completionHandler: { (success) in
                if (success) {
                    newDocumentURL = temporaryURL
                }
                if newDocumentURL != nil {
                    importHandler(newDocumentURL, .move)
                } else {
                    importHandler(nil, .none)
                }
            })
            connectionStringAlert.dismiss(animated: true, completion: nil)
        }))
        connectionStringAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            connectionStringAlert.dismiss(animated: true, completion: nil)
        }))
        present(connectionStringAlert, animated: true, completion: nil)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as? ConnectionViewController else { return }
        documentViewController.document = FrondDocument(fileURL: documentURL)

        let navigationController = UINavigationController(rootViewController: documentViewController)
        documentViewController.hidesBottomBarWhenPushed = false
        navigationController.hidesBottomBarWhenPushed = false
        navigationController.setToolbarHidden(false, animated: true)

        present(navigationController, animated: true, completion: nil)
    }
}


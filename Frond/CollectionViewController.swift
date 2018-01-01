//
//  CollectionViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import SpreadsheetView
import MongoKitten
import PanelKit

class CollectionViewController: UIViewController {
    @IBOutlet weak var panelView: UIView!
    var _panels: [PanelViewController] = []

    @IBOutlet weak var sheet: SpreadsheetView!
    @IBOutlet weak var queryBarButtonItem: UIBarButtonItem!
    var server: Server?
    var database: String = ""
    var collection: String = ""
    var documents: [Document] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        reload(query: Query())

        sheet.alwaysBounceVertical = true
        sheet.alwaysBounceHorizontal = true
        sheet.dataSource = self
        sheet.register(DocumentCell.self, forCellWithReuseIdentifier: "Document")
        sheet.register(HeaderCell.self, forCellWithReuseIdentifier: "Header")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "query" {
            guard let controller = (segue.destination as? UINavigationController)?.topViewController as? QueryEditorViewController else { return }
            controller.delegate = self
        }
    }

    @IBAction func share(_ sender: Any) {
        let data = documents.makeExtendedJSON().serializedString()
        let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        if let sender = sender as? UIBarButtonItem {
            activityController.popoverPresentationController?.barButtonItem = sender
        }
        present(activityController, animated: true, completion: nil)
    }
}

extension CollectionViewController: PanelManager {
    var panels: [PanelViewController] {
        set {
            _panels = newValue
        }
        get {
            return _panels
        }
    }

    var panelContentWrapperView: UIView {
        get {
            return panelView
        }
    }

    var panelContentView: UIView {
        get {
            return panelView
        }
    }
}

extension CollectionViewController: SpreadsheetViewDataSource {
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return documents.count + 1
    }

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return documents.reduce(0, { (r, document) in
            return max(r, document.dictionaryRepresentation.keys.count)
        })
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 200
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 44
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.row == 0, documents.count > 0 {
            guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier:  "Header", for: indexPath) as? HeaderCell else { fatalError() }
            let sampleDocument = documents[0]
            let documentDictionary: [String : Primitive] = sampleDocument.dictionaryRepresentation
            let key = documentDictionary.keys.index(documentDictionary.startIndex, offsetBy: indexPath.column)
            cell.textView.text = "\(documentDictionary[key].key)"
            return cell
        } else {
            guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier:  "Document", for: indexPath) as? DocumentCell else { fatalError() }
            let document = documents[indexPath.row-1]
            let sampleDocument: [String : Primitive] = document.dictionaryRepresentation
            let key = sampleDocument.keys.index(sampleDocument.startIndex, offsetBy: indexPath.column)
            let value = sampleDocument[key].value
            cell.value = value
            cell.delegate = self
            cell.textView.text = PrimitiveUtilities.summary(primitive: value)
            return cell
        }
    }
}

extension CollectionViewController: DocumentCellDelegate {
    private var randomColor: UIColor {
        get {
            let randomHue: CGFloat = CGFloat(Double(arc4random() % 1000) / 1000.0)
            return UIColor(hue: randomHue, saturation: 1.0, brightness: 0.8, alpha: 1.0)
        }
    }

    func showDetails(for document: Document, in cell: DocumentCell) {
        let indexPathForCell = sheet.indexPathForItem(at: cell.frame.origin)
        guard let indexPath = indexPathForCell else { return }
        let parentDocument = documents[indexPath.row-1]
        let columnTitle = parentDocument.keys[indexPath.column]

        guard let documentController = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetails") as? DocumentPanelViewController else { return }
        let panelController = PanelViewController(with: documentController, in: self)
        panels.append(panelController)
        documentController.document = document
        documentController.title = "\(parentDocument["_id"] ?? "Missing _id").\(columnTitle)"
        panelController.modalPresentationStyle = .popover
        panelController.popoverPresentationController?.sourceView = cell.contentView
        let color = randomColor
        documentController.view.backgroundColor = color
        cell.contentView.backgroundColor = color
        present(panelController, animated: true, completion: nil)
    }
}

extension CollectionViewController: QueryEditorDelegate {
    func queryUpdated(editor: QueryEditorViewController, query: Query) {
        queryBarButtonItem.title = "Query: \(query.queryDocument.dictionaryRepresentation.count)"
        reload(query: query)
    }
}

extension CollectionViewController {
    func reload(query: Query) {
        guard let server = server else { return }
        MongoDB.performQuery(on: server, database: database, collection: collection, query: query, completion: { (result) in
            if case let .success(resultDocuments) = result {
                DispatchQueue.main.async {
                    self.documents = resultDocuments
                    self.sheet.reloadData()
                }
            }
        })
        MongoDB.countQuery(on: server, database: database, collection: collection, query: query, completion: { (result) in
            if case let .success(count) = result {
                DispatchQueue.main.async {
                    self.navigationItem.prompt = "\(count) documents"
                }
            }
        })
    }
}

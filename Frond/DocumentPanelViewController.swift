//
//  DocumentPanelViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import Foundation
import UIKit
import MongoKitten
import PanelKit
import SpreadsheetView

class DocumentPanelViewController: UIViewController, PanelContentDelegate, HeaderCellDelegate {

    @IBOutlet weak var sheet: SpreadsheetView!
    var document: Document?
    var documentIsArray: Bool {
        get {
            return document?.validatesAsArray() ?? false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = document?["_id"].debugDescription
        }

        sheet.alwaysBounceVertical = true
        sheet.alwaysBounceHorizontal = true
        sheet.dataSource = self
        sheet.register(DocumentCell.self, forCellWithReuseIdentifier: "Document")
        sheet.register(HeaderCell.self, forCellWithReuseIdentifier: "Header")
    }

    var preferredPanelContentSize: CGSize {
        return CGSize(width: 320, height: 500)
    }

    var maximumPanelContentSize: CGSize {
        return CGSize(width: 500, height: 500)
    }

    var preferredPanelPinnedWidth: CGFloat {
        return 500
    }

    func showActions(for: HeaderCell) {
        dump("\(#function)")
    }
}

extension DocumentPanelViewController: SpreadsheetViewDataSource {
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return (document?.dictionaryRepresentation.count ?? 0)
    }

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return documentIsArray ? 1 : 2
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 200
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 44
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if documentIsArray {
            // Just the array entries
            guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier:  "Document", for: indexPath) as? DocumentCell else { fatalError() }
            guard let document = document else { fatalError() }

            let documentDictionary: [String : Primitive] = document.dictionaryRepresentation
            let key = documentDictionary.keys.index(documentDictionary.startIndex, offsetBy: indexPath.row)
            let value = documentDictionary[key].value
            cell.value = value
            cell.delegate = self
            cell.textView.text = PrimitiveUtilities.summary(primitive: value)
            return cell
        } else {
            if indexPath.column == 0 {
                guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier:  "Header", for: indexPath) as? HeaderCell else { fatalError() }
                guard let sampleDocument = document else { fatalError() }
                let documentDictionary: [String : Primitive] = sampleDocument.dictionaryRepresentation
                let key = documentDictionary.keys.index(documentDictionary.startIndex, offsetBy: indexPath.row)
                cell.textView.text = "\(documentDictionary[key].key)"
                cell.delegate = self
                return cell
            } else {
                guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier:  "Document", for: indexPath) as? DocumentCell else { fatalError() }
                guard let document = document else { fatalError() }

                let documentDictionary: [String : Primitive] = document.dictionaryRepresentation
                let key = documentDictionary.keys.index(documentDictionary.startIndex, offsetBy: indexPath.row)
                let value = documentDictionary[key].value
                cell.value = value
                cell.delegate = self
                cell.textView.text = PrimitiveUtilities.summary(primitive: value)

                return cell
            }
        }
    }
}

extension DocumentPanelViewController: DocumentCellDelegate {
    func showDetails(for document: Document, in cell: DocumentCell) {
        let indexPathForCell = sheet.indexPathForItem(at: cell.frame.origin)
        guard let indexPath = indexPathForCell else { return }
        let cellTitle = documentIsArray ? "\(indexPath.row)" : document.keys[indexPath.row-1]

        guard let documentController = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetails") as? DocumentPanelViewController else { return }
        documentController.document = document
        documentController.title = (title ?? "") + ".\(cellTitle)"
        navigationController?.pushViewController(documentController, animated: true)
    }
}

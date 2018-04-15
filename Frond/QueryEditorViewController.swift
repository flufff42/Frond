//
//  QueryEditorViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import MongoKitten
import Highlightr

protocol QueryEditorDelegate: class {
    func queryUpdated(editor: QueryEditorViewController, query: Query)
    func saveQuery(queryDocumentString: QueryDocumentString)
}

class QueryEditorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var queryParsingResultTextView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: QueryEditorDelegate?

    var attributedStorage: CodeAttributedString?
    var layoutManager: NSLayoutManager?
    var textContainer: NSTextContainer?
    var attributedTextView: UITextView?
    var savedQueries: [QueryDocumentString]?

    override func viewDidLoad() {
        attributedStorage = CodeAttributedString()
        attributedStorage?.language = "JSON"
        attributedStorage?.highlightr.setTheme(to: "obsidian")

        layoutManager = NSLayoutManager()
        guard let layoutManager = layoutManager else { return }
        attributedStorage?.addLayoutManager(layoutManager)

        textContainer = NSTextContainer(size: view.bounds.size)
        guard let textContainer = textContainer else { return }
        layoutManager.addTextContainer(textContainer)

        attributedTextView = UITextView(frame: queryParsingResultTextView.bounds, textContainer: textContainer)
        guard let attributedTextView = attributedTextView else { return }
        attributedTextView.translatesAutoresizingMaskIntoConstraints = false
        attributedTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        attributedTextView.backgroundColor = .black

        attributedTextView.autocorrectionType = .no
        attributedTextView.autocapitalizationType = .none
        attributedTextView.smartDashesType = .no
        attributedTextView.smartQuotesType = .no

        stackView.insertArrangedSubview(attributedTextView, at: 0)

        if let savedQueries = savedQueries {
            loadQueriesBarButton.isEnabled = savedQueries.count > 0
        } else {
            loadQueriesBarButton.isEnabled = false
        }
        saveQueryBarButton.isEnabled = false
    }

    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var loadQueriesBarButton: UIBarButtonItem!
    @IBAction func loadSavedQueries(_ sender: Any) {
        let actionController = UIAlertController(title: "Saved Queries", message: "Choose a saved query", preferredStyle: .actionSheet)
        if let queries = savedQueries {
            for query in queries {
                actionController.addAction(UIAlertAction(title: query, style: .default, handler: { (action) in
                    self.attributedTextView?.text = action.title
                    self.validateQuery(self.attributedTextView as Any)
                }))
            }
            actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                actionController.dismiss(animated: true, completion: nil)
            }))
            actionController.popoverPresentationController?.barButtonItem = loadQueriesBarButton
            present(actionController, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var saveQueryBarButton: UIBarButtonItem!
    @IBAction func saveQuery(_ sender: Any) {
        guard let query = attributedTextView?.text else { return }
        delegate?.saveQuery(queryDocumentString: query)
    }

    @IBAction func validateQuery(_ sender: Any) {
        guard let query = attributedTextView?.text else {
            return
        }
        switch MongoDB.validate(documentString: query) {
        case let .success(q):
            DispatchQueue.main.async {
                self.delegate?.queryUpdated(editor: self, query: q)
                self.queryParsingResultTextView.text = "\(q.queryDocument)"
                self.saveQueryBarButton.isEnabled = true
            }
        case let .error(e):
            DispatchQueue.main.async {
                self.queryParsingResultTextView.text = "\(e)"
                self.saveQueryBarButton.isEnabled = false
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            validateQuery(textView)
            return false
        }
        return true
    }
}


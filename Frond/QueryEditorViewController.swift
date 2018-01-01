//
//  QueryEditorViewController.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import MongoKitten
import Highlightr

protocol QueryEditorDelegate {
    func queryUpdated(editor: QueryEditorViewController, query: Query)
}

class QueryEditorViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var queryParsingResultTextView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    var delegate: QueryEditorDelegate?

    var attributedStorage: CodeAttributedString?
    var layoutManager: NSLayoutManager?
    var textContainer: NSTextContainer?
    var attributedTextView: UITextView?

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
    }

    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            }
        case let .error(e):
            DispatchQueue.main.async {
                self.queryParsingResultTextView.text = "\(e)"
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


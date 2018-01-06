//
//  DocumentCell.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import MongoKitten
import SpreadsheetView

protocol DocumentCellDelegate: class {
    func showDetails(for: Document, in: DocumentCell)
}

class DocumentCell: Cell {
    var indexPath: IndexPath?
    var value: Primitive?
    var delegate: DocumentCellDelegate?
    let textView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textView)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }

    @objc func cellTapped() {
        guard let document = value as? Document else { return }
        delegate?.showDetails(for: document, in: self)
    }
}

//
//  HeaderCell.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit
import SpreadsheetView

protocol HeaderCellDelegate: class {
    func showActions(for: HeaderCell)
}

class HeaderCell: Cell {
    weak var delegate: HeaderCellDelegate?
    let textView = UILabel()

    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                delegate?.showActions(for: self)

            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textView)
        contentView.backgroundColor = .gray
        selectedBackgroundView?.backgroundColor = .green
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

//
//  PanelSheetView.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import SpreadsheetView
import UIKit

class PanelSheetView: UIView {
    @IBOutlet weak var sheet: SpreadsheetView!
    @IBOutlet weak var panelContainer: UIView!

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let defaultHitView = super.hitTest(point, with: event)
        let panelHit = !(panelContainer.hitTest(point, with: event)?.isEqual(panelContainer) ?? true)
        if !panelHit {
            let sheetHitTestView = sheet.hitTest(convert(point, to: sheet), with: event)
            return sheetHitTestView
        }
        return defaultHitView
    }

    override var isExclusiveTouch: Bool {
        get { return false }
        set {}
    }
}

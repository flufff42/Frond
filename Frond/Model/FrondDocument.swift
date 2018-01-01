//
//  FrondDocument.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit

struct FrondDocumentModel: Codable {
    var connectionString: String
}

class FrondDocument: UIDocument {

    var connectionString: String?
    
    override func contents(forType typeName: String) throws -> Any {
        return try JSONEncoder().encode(FrondDocumentModel(connectionString: connectionString ?? ""))
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contentsData = contents as? Data else { fatalError("Contents \(contents) are not Data") }
        let document = try JSONDecoder.init().decode(FrondDocumentModel.self, from: contentsData)
        connectionString = document.connectionString
    }
}


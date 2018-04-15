//
//  FrondDocument.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import UIKit

typealias CollectionName = String
typealias QueryDocumentString = String

struct FrondDocumentModel: Codable {
    var connectionString: String
    var savedQueries: [CollectionName: [QueryDocumentString]]
}

class FrondDocument: UIDocument {

    var connectionString: String?
    var savedQueries: [CollectionName: [QueryDocumentString]]?

    override func contents(forType typeName: String) throws -> Any {
        let documentModel = FrondDocumentModel(connectionString: connectionString ?? "", savedQueries: savedQueries ?? [:])
        return try JSONEncoder().encode(documentModel)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contentsData = contents as? Data else { fatalError("Contents \(contents) are not Data") }
        let document = try JSONDecoder.init().decode(FrondDocumentModel.self, from: contentsData)
        connectionString = document.connectionString
        savedQueries = document.savedQueries
    }
}


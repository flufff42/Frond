//
//  MongoDB.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import Foundation
import MongoKitten

enum Result<T> {
    case success(T)
    case error(Error)
}

extension String: Error {}

struct MongoDB {
    static func connect(connectionString: String, completion: ((Result<Server>) -> ())) {
        do {
            let parsedSettings = try ClientSettings(connectionString)
            let server = try Server(parsedSettings)
            completion(.success(server))
        } catch {
            completion(.error(error))
        }
    }

    static func validate(documentString: String) -> (Result<Query>) {
        do {
            guard let documentStringData = documentString.data(using: .utf8) else {
                return .error("Failed to get UTF-8 data from \(documentString)")
            }
            do {
                _ = try JSONSerialization.jsonObject(with: documentStringData, options: [])
            } catch {
                return .error("Failed to serialize document string as JSON \(error)")
            }
            guard let document = try Document(extendedJSON: documentString) else {
                return .error("Valid — nil — document")
            }
            return .success(Query(document))
        } catch {
            return .error(error)
        }
    }

    static func listCollections(on server: Server, database: String, completion: @escaping ((Result<[MongoKitten.Collection]>) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let myDatabase = MongoKitten.Database(named: database, atServer: server)
                let collections = try myDatabase.listCollections()
                completion(.success(Array(collections)))
            } catch {
                completion(.error(error))
            }
        }
    }

    static func performQuery(on server: Server, database: String, collection: String, query: Query, completion: @escaping ((Result<[Document]>) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let myDatabase = MongoKitten.Database(named: database, atServer: server)
                let collection = myDatabase[collection]
                let documents = try collection.find(query, limitedTo: 50) // FIXME
                completion(.success(Array(documents)))
            } catch {
                completion(.error(error))
            }
        }
    }

    static func countQuery(on server: Server, database: String, collection: String, query: Query, completion: @escaping ((Result<Int>) -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let myDatabase = MongoKitten.Database(named: database, atServer: server)
                let collection = myDatabase[collection]
                let count = try collection.count(query)
                completion(.success(count))
            } catch {
                completion(.error(error))
            }
        }
    }
}

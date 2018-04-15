//
//  PrimitiveUtilities.swift
//  Frond
//
//  Created by Seán Labastille on 01.01.18.
//

import Foundation
import MongoKitten

struct PrimitiveUtilities {
    static func summary(primitive: Primitive) -> String {
        switch primitive {
        case is String, is Int, is Int32, is Int64, is Date, is Bool, is NSNull:
            return "\(primitive)"
        case let id as BSON.ObjectId:
            return "Object ID \(id.hexString)"
        case let document as BSON.Document:
            return "Document \(document)"
        default:
            return "Unhandled value type"
        }
    }
}

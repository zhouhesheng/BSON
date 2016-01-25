//
//  Document.swift
//  BSON
//
//  Created by Robbert Brandsma on 23-01-16.
//  Copyright © 2016 Robbert Brandsma. All rights reserved.
//

import Foundation

public struct Document {
    var elements = [String : BSONElementConvertible]()
    
    init(data: NSData) throws {
        var byteArray = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&byteArray, length: byteArray.count)
        
        try self.init(data: byteArray)
    }
    
    init(data: [UInt8]) throws {
        // A BSON document cannot be smaller than 5 bytes (which would be an empty document)
        guard data.count >= 5 else {
            throw DeserializationError.InvalidDocumentLength
        }
        
        // The first four bytes of a document represent the total size of the document
        let documentLength = Int32(littleEndian: UnsafePointer<Int32>(data).memory)
        guard Int(documentLength) == data.count else {
            throw DeserializationError.InvalidDocumentLength
        }
        
        // Parse! Loop over the element list.
        var position = 4
        while position < Int(documentLength) {
            // The first byte in an element is the element type
            let elementTypeValue = data[position]
            position += 1
            
            guard let elementType = ElementType(rawValue: elementTypeValue) else {
                // TODO: Handle 0000 0000 here. That's the end of the document.
                throw DeserializationError.UnknownElementType
            }
            
            // Now that we have the type, parse the name
            guard let stringTerminatorIndex = data[position...data.endIndex].indexOf(0) else {
                throw DeserializationError.ParseError
            }
            
            let keyData = Array(data[position...stringTerminatorIndex])
            let elementName = try String.instantiate(bsonData: keyData)
            
            position = stringTerminatorIndex + 1
            
            // We now have the key of the element and are at the position of the data itself. Let's intialize it.
            let length = elementType.type.bsonLength
            let elementData: [UInt8]
            switch length {
            case .Fixed(let length):
                elementData = Array(data[position...position+length])
            case .Undefined:
                elementData = data
            case .NullTerminated:
                guard let terminatorIndex = data[position...data.endIndex].indexOf(0) else {
                    throw DeserializationError.ParseError
                }
                
                elementData = Array(data[position...terminatorIndex])
            }
            
            let instance = try elementType.type.instantiate(bsonData: elementData)
            
            self.elements[elementName] = instance
        }
    }
}

extension Document {
    /// Returns true if this Document is an array and false otherwise.
    func validatesAsArray() -> Bool {
        var current = -1
        for (key, _) in self.elements {
            guard let index = Int(key) else {
                return false
            }
            
            if current == index-1 {
                current++
            } else {
                return false
            }
        }
        return true
    }
}

extension Document : BSONElementConvertible {
    public var elementType: ElementType {
        return self.validatesAsArray() ? .Array : .Document
    }
    
    public var bsonData: [UInt8] {
        abort()
    }
    
    public static func instantiate(bsonData data: [UInt8]) throws -> Document {
        abort()
    }
    
    public static let bsonLength = BsonLength.Undefined
}
extension Double : BSONElementConvertible {
    public var elementType: ElementType {
        return .Double
    }

    public static func instantiate(bsonData data: [UInt8]) throws -> Double {
        var ditched = 0
        
        return try instantiate(bsonData: data, consumedBytes: &ditched)
    }
    
    public static func instantiate(bsonData data: [UInt8], inout consumedBytes: Int) throws -> Double {
        guard data.count == 8 else {
            throw DeserializationError.InvalidElementSize
        }
        
        let double = UnsafePointer<Double>(data).memory
        consumedBytes = 8
        return double
    }
    
    public var bsonData: [UInt8] {
        var double = self
        return withUnsafePointer(&double) {
            Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(Double)))
        }
    }
    
    public static let bsonLength = BsonLength.Fixed(length: 8)
}
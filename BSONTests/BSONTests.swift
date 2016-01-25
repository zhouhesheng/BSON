//
//  BSONTests.swift
//  BSONTests
//
//  Created by Robbert Brandsma on 23-01-16.
//  Copyright © 2016 Robbert Brandsma. All rights reserved.
//

import XCTest
@testable import BSON

class BSONTests: XCTestCase {
    
    func testDoubleSerialization() {
        // This is 5.05
        let rawData: [UInt8] = [0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x14, 0x40]
        let double = try! Double.instantiate(bsonData: rawData)
        XCTAssertEqual(double, 5.05, "Instantiating a Double from BSON data works correctly")
        
        let generatedData = 5.05.bsonData
        XCTAssert(generatedData == rawData, "Converting a Double to BSON data results in the correct data")
    }
    
    func testStringSerialization() {
        // This is "ABCD"
        let rawData: [UInt8] = [0x41, 0x42, 0x43, 0x44, 0x00]
        let double = try! String.instantiate(bsonData: rawData)
        XCTAssertEqual(double, "ABCD", "Instantiating a String from BSON data works correctly")
        
        let generatedData = "ABCD".bsonData
        XCTAssert(generatedData == rawData, "Converting a String to BSON data results in the correct data")
    }
    
    func testBooleanSerialization() {
        let falseData: [UInt8] = [0x00]
        let falseBoolean = try! Bool.instantiate(bsonData: falseData)
        
        XCTAssert(!falseBoolean, "Checking if 0x00 is false")
        
        let trueData: [UInt8] = [0x01]
        let trueBoolean = try! Bool.instantiate(bsonData: trueData)
        
        XCTAssert(trueBoolean, "Checking if 0x01 is true")
    }
    
    func testInt32Serialization() {
        // This is 5.05
        let rawData: [UInt8] = [0xc2, 0x07, 0x00, 0x00]
        let double = try! Int32.instantiate(bsonData: rawData)
        XCTAssertEqual(double, 1986, "Instantiating an int32 from BSON data works correctly")
        
        let generatedData = (1986 as Int32).bsonData
        XCTAssert(generatedData == rawData, "Converting an int32 to BSON data results in the correct data")
    }
    
    func testInt64Serialization() {
        // This is 5.05
        let rawData: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        let double = try! Int.instantiate(bsonData: rawData)
        XCTAssertEqual(double, 1, "Instantiating an integer from BSON data works correctly")
        
        let generatedData = (1 as Int).bsonData
        XCTAssert(generatedData == rawData, "Converting an integer to BSON data results in the correct data")
    }
    
    func testTimestampSerialization() {
        let rawData: [UInt8] = [0x12, 0x03, 0xa4, 0x56, 0x00, 0x00, 0x00, 0x00]
        let date = try! NSDate.instantiate(bsonData: rawData)
        
        XCTAssertEqual(date.timeIntervalSince1970, 1453589266, "Instantiating NSDate from BSON data works correctly")
        
        let generatedData = NSDate(timeIntervalSince1970: Double(1453589266)).bsonData
        XCTAssert(generatedData == rawData, "Converting NSDate to BSON data results in the corrrect timestamp")
    }
    
    func testDocumentSerialization() {
        //{"BSON": ["awesome", 5.05, 1986]}
        //let document = try Document(data: [0x31, 0x00, 0x00, 0x00, 0x04, 0x42, 0x53, 0x4f, 0x4e, 0x00, 0x26, 0x00, 0x00, 0x00, 0x02, 0x30, 0x00, 0x08, 0x00, 0x00, 0x00, 0x61, 0x77, 0x65, 0x73, 0x6f, 0x6d, 0x65, 0x00, 0x01, 0x31, 0x00, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x14, 0x40, 0x10, 0x32, 0x00, 0xc2, 0x07, 0x00, 0x00, 0x00, 0x00]))
        
        // {"hello": "world"}
        let document = try! Document.instantiate(bsonData: [0x16, 0x00, 0x00, 0x00, 0x02, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x06, 0x00, 0x00, 0x00, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x00, 0x00])
        
        XCTAssert(document.elements["hello"] as! String == "world", "Our document contains the proper information")
    }
}

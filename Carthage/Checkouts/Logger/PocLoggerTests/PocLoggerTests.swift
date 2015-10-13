/*
The MIT License (MIT)

Copyright (c) 2015 Bertrand Marlier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
*/
//
//  PocLoggerTests.swift
//  PocLoggerTests
//

import XCTest
import Logger

class PocLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Filtering1()
    {
        Logger.set(AllowedLevel: .Warning)
        Logger.set(RequiredLevel: .Error)
        
        let log = Logger()
        
        log.critical("%l")
        
        log.debug("debug")
        log.info("info")
        log.warning("warning")
        log.error("error")
        log.critical("critical")

        XCTAssert(log.isActive(Level: .Debug)       == false)   // not allowed
        XCTAssert(log.isActive(Level: .Info)        == false)   // not allowed
        XCTAssert(log.isActive(Level: .Warning)     == true)    // allowed but not requested
        XCTAssert(log.isActive(Level: .Error)       == true)    // required (and requested)
        XCTAssert(log.isActive(Level: .Critical)    == true)    // required (and requested)
        
        log.critical("%l")
        
        log.request(Level: .Critical)
        
        log.debug("debug")
        log.info("info")
        log.warning("warning")
        log.error("error")
        log.critical("critical")
        
        log.critical("%l")
        
        XCTAssert(log.isActive(Level: .Debug)       == false)   // not allowed
        XCTAssert(log.isActive(Level: .Info)        == false)   // not allowed
        XCTAssert(log.isActive(Level: .Warning)     == false)   // allowed but not requested
        XCTAssert(log.isActive(Level: .Error)       == true)    // required
        XCTAssert(log.isActive(Level: .Critical)    == true)    // required (and requested)
}
    
    func testPerformance_NotAllowedRequested()
    {
        let log = Logger()
        
        log.request(Level: .All)
        
        Logger.set(RequiredLevel: .None)
        Logger.set(AllowedLevel: .Warning)
        
        self.measureBlock
        {
            for i in 0..<1000000
            {
                log.debug("%f %l \(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)")
            }
        }
    }
    
    func testPerformance_AllowedNotRequested()
    {
        let log = Logger()
        
        log.request(Level: .None)
        
        Logger.set(RequiredLevel: .None)
        Logger.set(AllowedLevel: .All)
        
        self.measureBlock
        {
            for i in 0..<1000000
            {
                log.debug("%f %l \(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)")
            }
        }
    }
   
    func testPerformance_NotRequiredRequested()
    {
        let log = Logger()
        
        log.request(Level: .Debug)
        
        Logger.set(RequiredLevel: .None)
        Logger.set(AllowedLevel: .All)
        
        Logger.set(DefaultSink: NoLogSink())
        
        self.measureBlock
        {
            for i in 0..<1000
            {
                log.debug("%f %l \(i)\(i)\(i)\(i)\(i)\(i)\(i)\(i)")
            }
        }
    }

}

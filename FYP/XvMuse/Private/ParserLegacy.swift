//
//  Parser.swift
//  XvMuse
//
//  Created by Jason Snell on 6/16/20.
//  Copyright © 2020 Jason Snell. All rights reserved.
//

import Foundation

class ParserLegacy {
    
    private let debug:Bool = true
    
    //MARK: - PACKET INDEX
    internal func getPacketIndex(fromBytes:[UInt8]) -> UInt16 {
        let twoByteArr:[UInt8] = [fromBytes[0], fromBytes[1]]
        return Bytes.getUInt16(fromBytes: twoByteArr)
    }
    
    //MARK: - EEG -
    internal func getEEGSamples(from bytes:[UInt8]) -> [Double] {
        //convert UInt8 array into a UInt12 array
        let UInt12Samples:[UInt16] = Bytes.constructUInt12Array(fromUInt8Array: bytes)
        //process these samples into the correct range
        return UInt12Samples.map { 0.48828125 * Double(Int($0) - 2048) } //0x800 = 2048
    }
    
    //MARK: - CONTROL MESSAGES -
    private var controlMsg:String = ""
    
    internal func parse(controlLine:Data?) -> [String:Any]? {
        if let _controlLine:Data = controlLine {
            let lengthOfString:Int = Int(_controlLine[0])
            for i in 1...lengthOfString {
                let byte:UInt8 = _controlLine[i]
                let charFromByte:Character = Character(UnicodeScalar(byte))
                controlMsg += String(charFromByte)
                
                if (charFromByte == "}") {
                    let message = controlMsg
                    var json: [String: Any] = [:]
                    let end = message.endIndex
                    var searchIndex = message.startIndex
                    
                    while let colonIndex = message[searchIndex...].firstIndex(of: ":") {
                            guard let keyEndQuote = message[..<colonIndex].lastIndex(of: "\"") else {
                                searchIndex = message.index(after: colonIndex)
                                continue
                            }
                            guard let keyStartQuote = message[..<keyEndQuote].lastIndex(of: "\"") else {
                                searchIndex = message.index(after: colonIndex)
                                continue
                            }
                            let rawKey = String(message[message.index(after: keyStartQuote)..<keyEndQuote])
                            var valueIndex = message.index(after: colonIndex)
                            
                            while valueIndex < end && message[valueIndex].isWhitespace {
                                valueIndex = message.index(after: valueIndex)
                            }
                            if valueIndex >= end { break }
                            
                            var rawValue: String
                            if message[valueIndex] == "\"" {
                                let valueStart = message.index(after: valueIndex)
                                guard let valueEndQuote = message[valueStart...].firstIndex(of: "\"") else {
                                    searchIndex = message.index(after: colonIndex)
                                    continue
                                }
                                rawValue = String(message[valueStart..<valueEndQuote])
                                searchIndex = message.index(after: valueEndQuote)
                            } else {
                                let valueStart = valueIndex
                                var valueEnd = valueIndex
                                while valueEnd < end && message[valueEnd] != "," && message[valueEnd] != "}" {
                                    valueEnd = message.index(after: valueEnd)
                                }
                                rawValue = String(message[valueStart..<valueEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
                                searchIndex = valueEnd
                            }
                            
                            let value: Any
                            if let intVal = Int(rawValue) { value = intVal }
                            else if let doubleVal = Double(rawValue) { value = doubleVal }
                            else { value = rawValue }
                            
                            if json[rawKey] == nil { json[rawKey] = value }
                    }
                    controlMsg = ""
                    if !json.isEmpty { return json }
                    else { return nil }
                }
            }
        }
        return nil
    }
}

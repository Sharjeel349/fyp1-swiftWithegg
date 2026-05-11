//
//  ParserAthena.swift
//  XvMuse
//
//  Created by Jason Snell on 12/1/25.
//  Copyright © 2025 Jason Snell. All rights reserved.
//

// from: https://github.com/DominiqueMakowski/OpenMuse/

/*
 Athena Muse BLE Message Parser
 ============================================

 Implementation that follows the actual message structure:
 MESSAGE → PACKET → DATA SUBPACKETS

 Message Structure:
 ------------------
 Each BLE MESSAGE contains one or more PACKETS. Each PACKET has a 14-byte header
 followed by a data section containing multiple DATA SUBPACKETS:

 MESSAGE (BLE transmission with timestamp)
   └─ PACKET (14-byte header + data section)
        ├─ First Subpacket: Raw sensor data (no TAG, no header)
        └─ Additional Subpackets: [TAG (1 byte)][Header (4 bytes)][Data (variable)]
             ├─ TAG: Sensor type identifier (e.g., 0x47=ACCGYRO, 0x12=EEG8)
             ├─ subpacket_index: Per-sensor-type sequence counter (0-255, wraps)
             ├─ Unknown bytes: 3 metadata bytes (purpose unknown)
             └─ Sensor data: Variable length depending on sensor type

 Timestamp Calculation & Device Timing:
 ---------------------------------------
 Device timestamps (packet_time) are derived from a 256 kHz hardware clock with 3.906 µs resolution.
 Multiple packets often share identical packet_time values (~11-30% are duplicates).

 Timestamp generation per message:
   1. Sort packets by (packet_time, packet_index, subpacket_index)
      - packet_index: Packet sequence counter (0-255), ensures correct ordering of duplicates
      - Analysis: 100% sequential in duplicate groups (1871/1871 tested)
   2. Use first packet's packet_time as anchor
   3. Generate uniform timestamps: anchor + (sample_index / sampling_rate)

 Hardware Timing Artifacts:
   - ~4% of packet_time values have timing inversions (timestamps go backwards)
   - packet_index remains sequential (100% accurate for packet order)
   - Inversions likely due to async sensor buffering and clock jitter
   - Final monotonicity ensured by stream.py buffering/sorting before LSL output
 */

//
//  ParserAthena.swift
//  XvMuse
//
//  Created by Jason Snell on 12/1/25.
//  Copyright © 2025 Jason Snell. All rights reserved.
//

import Foundation

protocol ParserAthenaDelegate: AnyObject {
    // Only keeping the EEG delegate since we removed Accel, Battery, and PPG
    func didReceiveAthenaEEGBuffers(
        packetIndex: UInt8,
        timestamp: TimeInterval,
        tp9: [Float],
        af7: [Float],
        af8: [Float],
        tp10: [Float]
    )
}

class ParserAthena {
    
    init(){}
    public weak var delegate: ParserAthenaDelegate?
    
    // Buffer one shared EEG window size, mirroring legacy Muse
    private let eegWindowSize = 12
    
    // Per-channel EEG buffers
    private var tp9Buffer  = RingBuffer<Float>(capacity: 64)
    private var af7Buffer  = RingBuffer<Float>(capacity: 64)
    private var af8Buffer  = RingBuffer<Float>(capacity: 64)
    private var tp10Buffer = RingBuffer<Float>(capacity: 64)
    
    private enum AthenaSensorType {
        case eeg
        case accgyro
        case optics
        case battery
        case unknown
    }
    
    private struct AthenaSensorConfig {
        let type: AthenaSensorType
        let nChannels: Int
        let nSamples: Int
        let rate: Double
        let dataLen: Int
    }
    
    private enum Athena {
        static let packetHeaderSize = 14
        static let subpacketHeaderSize = 5
        static let deviceClockHz: Double = 256_000.0
        
        static let sensors: [UInt8: AthenaSensorConfig] = [
            0x11: .init(type: .eeg,     nChannels: 4,  nSamples: 4, rate: 256.0, dataLen: 28),
            0x12: .init(type: .eeg,     nChannels: 8,  nSamples: 2, rate: 256.0, dataLen: 28),
            0x34: .init(type: .optics,  nChannels: 4,  nSamples: 3, rate:  64.0, dataLen: 30),
            0x35: .init(type: .optics,  nChannels: 8,  nSamples: 2, rate:  64.0, dataLen: 40),
            0x36: .init(type: .optics,  nChannels: 16, nSamples: 1, rate:  64.0, dataLen: 40),
            0x47: .init(type: .accgyro, nChannels: 6,  nSamples: 3, rate:  52.0, dataLen: 36),
            0x53: .init(type: .unknown, nChannels: 0,  nSamples: 0, rate:   0.0, dataLen: 24),
            0x98: .init(type: .battery, nChannels: 1,  nSamples: 1, rate:   1.0, dataLen: 20),
        ]
        static let eegScale: Double = 1450.0 / 16383.0
    }
    
    func parse(bytes: [UInt8], timestamp: Double) {
        var offset = 0
        let count = bytes.count
        
        while offset < count {
            guard offset + Athena.packetHeaderSize <= count else { break }
            let packetLen = Int(bytes[offset])
            guard packetLen > 0, offset + packetLen <= count else { break }
            
            let packetBytes = Array(bytes[offset ..< offset + packetLen])
            let packetIndex: UInt8 = packetBytes[1]
            let packetTimeRaw = UInt32(packetBytes[2])
                | (UInt32(packetBytes[3]) << 8)
                | (UInt32(packetBytes[4]) << 16)
                | (UInt32(packetBytes[5]) << 24)
            let packetTimeSec = Double(packetTimeRaw) / Athena.deviceClockHz
            
            let packetId: UInt8 = packetBytes[9]
            let packetConfig = Athena.sensors[packetId]
            let packetType = packetConfig?.type
            let byte13: UInt8 = packetBytes[13]
            
            let packetValid = (packetType != nil && byte13 == 0 && packetLen >= Athena.packetHeaderSize)
            let dataSection: [UInt8] = packetBytes.count > Athena.packetHeaderSize ? Array(packetBytes[Athena.packetHeaderSize ..< packetBytes.count]) : []
            
            parseAthenaDataSubpackets(
                packetValid: packetValid,
                packetType: packetType,
                packetId: packetId,
                packetConfig: packetConfig,
                packetIndex: packetIndex,
                packetTimeRaw: packetTimeRaw,
                packetTimeSec: packetTimeSec,
                data: dataSection,
                timestamp: timestamp
            )
            offset += packetLen
        }
    }
    
    private func parseAthenaDataSubpackets(
        packetValid: Bool,
        packetType: AthenaSensorType?,
        packetId: UInt8,
        packetConfig: AthenaSensorConfig?,
        packetIndex: UInt8,
        packetTimeRaw: UInt32,
        packetTimeSec: Double,
        data: [UInt8],
        timestamp: Double
    ) {
        var offset = 0
        let count = data.count
       
        if packetValid, let type = packetType, let cfg = packetConfig {
            let len = cfg.dataLen
            if len > 0, offset + len <= count {
                let firstDataBytes = Array(data[offset ..< offset + len])
                handleAthenaSubpacket(sensorType: type, tagByte: packetId, dataBytes: firstDataBytes, packetIndex: packetIndex, timestamp: timestamp)
                offset += len
            }
        }
        
        while offset + Athena.subpacketHeaderSize <= count {
            let tagByte = data[offset]
            guard let cfg = Athena.sensors[tagByte] else { break }
            let dataLen = cfg.dataLen
            if dataLen == 0 { break }
            guard offset + Athena.subpacketHeaderSize + dataLen <= count else { break }
            
            let start = offset + Athena.subpacketHeaderSize
            let end = start + dataLen
            let dataBytes = Array(data[start ..< end])
            
            handleAthenaSubpacket(sensorType: cfg.type, tagByte: tagByte, dataBytes: dataBytes, packetIndex: packetIndex, timestamp: timestamp)
            offset = end
        }
    }
    
    private func athenaBytesToBits(_ data: [UInt8], maxBytes: Int) -> [UInt8] {
        var bits: [UInt8] = []
        bits.reserveCapacity(maxBytes * 8)
        for i in 0..<min(maxBytes, data.count) {
            let b = data[i]
            for bitPos in 0..<8 {
                bits.append((b >> bitPos) & 0x01)
            }
        }
        return bits
    }

    private func athenaExtractPackedInt(bits: [UInt8], bitStart: Int, bitWidth: Int) -> Int {
        var value = 0
        for bitIdx in 0..<bitWidth {
            if bits[bitStart + bitIdx] != 0 { value |= (1 << bitIdx) }
        }
        return value
    }
    
    private func decodeAthenaEEG(dataBytes: [UInt8], nChannels: Int) -> [[Float]]? {
        guard dataBytes.count >= 28 else { return nil }
        let nSamples = (nChannels == 4) ? 4 : 2
        let bits = athenaBytesToBits(dataBytes, maxBytes: 28)
        var rows: [[Float]] = Array(repeating: Array(repeating: 0, count: nChannels), count: nSamples)
        
        for sampleIdx in 0..<nSamples {
            for chIdx in 0..<nChannels {
                let valueIndex = sampleIdx * nChannels + chIdx
                let bitStart = valueIndex * 14
                let intValue = athenaExtractPackedInt(bits: bits, bitStart: bitStart, bitWidth: 14)
                let scaled = Double(intValue) * Athena.eegScale
                rows[sampleIdx][chIdx] = Float(scaled)
            }
        }
        return rows
    }
    
    private func handleAthenaSubpacket(
        sensorType: AthenaSensorType,
        tagByte: UInt8,
        dataBytes: [UInt8],
        packetIndex: UInt8,
        timestamp: Double
    ) {
        switch sensorType {
        case .eeg:
            guard let cfg = Athena.sensors[tagByte] else { return }
            guard let rows = decodeAthenaEEG(dataBytes: dataBytes, nChannels: cfg.nChannels) else { return }
            
            for sample in rows {
                guard sample.count >= 4 else { continue }
                tp9Buffer.append(sample[0])
                af7Buffer.append(sample[1])
                af8Buffer.append(sample[2])
                tp10Buffer.append(sample[3])
            }
            
            if tp9Buffer.count >= eegWindowSize &&
               af7Buffer.count >= eegWindowSize &&
               af8Buffer.count >= eegWindowSize &&
               tp10Buffer.count >= eegWindowSize {
                
                let tp9Window  = tp9Buffer.last(eegWindowSize)
                let af7Window  = af7Buffer.last(eegWindowSize)
                let af8Window  = af8Buffer.last(eegWindowSize)
                let tp10Window = tp10Buffer.last(eegWindowSize)
                
                delegate?.didReceiveAthenaEEGBuffers(
                    packetIndex: packetIndex,
                    timestamp: timestamp,
                    tp9: tp9Window,
                    af7: af7Window,
                    af8: af8Window,
                    tp10: tp10Window
                )
            }
            
        default:
            // Ignore non-EEG packets (Accel, PPG, Battery)
            break
        }
    }
}

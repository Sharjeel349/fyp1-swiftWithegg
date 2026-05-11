//
//  XvMuse.swift
//  XvMuse
//
//  Created by Jason Snell on 6/14/20.
//  Copyright © 2020 Jason Snell. All rights reserved.
//

import Foundation
import CoreBluetooth

// We have removed PPG (Heart Rate), Accel (Movement), and Battery to keep the app
// lightweight and focused strictly on EEG Brainwaves for the AI Advisor.

public protocol XvMuseDelegate: AnyObject {
    
    // Brainwaves
    func didReceive(eegPacket: XvEEGPacket)
    
    // Commands
    func didReceive(commandResponse: [String:Any])
    
    // Bluetooth Connection Updates
    func museIsAttemptingConnection()
    func museIsConnecting()
    func museDidConnect()
    func museDidDisconnect()
    func museLostConnection()
    func didFindNearby(muses: [CBPeripheral])
}

//MARK: - PACKETS -
internal class MusePacket {
    internal var packetIndex: UInt16 = 0
    internal var sensor: Int = 0 // 0 to 4: tp10 af8 tp9 af7 aux
    internal var timestamp: Double = 0 // milliseconds since packet creation
    internal var samples: [Double] = [] // 12 samples of EEG sensor data
    
    internal init(packetIndex: UInt16, sensor: Int, timestamp: Double, samples: [Double]){
        self.packetIndex = packetIndex
        self.sensor = sensor
        self.timestamp = timestamp
        self.samples = samples
    }
}

//MARK: - EEG
internal class MuseEEGPacket: MusePacket {}

//MARK: - MUSE -
public class XvMuse: MuseBluetoothObserver, ParserAthenaDelegate {

    //MARK: - vars
    public var bluetooth: MuseBluetooth
    public weak var delegate: XvMuseDelegate?
    
    //device version
    private var deviceName: XvDeviceName?
    private var majorVersion: String?
    private var minorVersion: String?
    
    //MARK: - Private
    private var _eeg: MuseEEG
    private var _testEEG: MuseEEG

    //helper classes
    private let _parserLegacy: ParserLegacy = ParserLegacy()
    private let _parserAthena: ParserAthena = ParserAthena()
    private var _fft: FFTManager = FFTManager()
    
    private let _systemLaunchTime: Double = Date().timeIntervalSince1970
    private var deviceUUID: String?
    private let debug: Bool = true
    
    private var eegSensorBytes: [[[UInt8]]] = Array(repeating: [], count: 4)
    
    public func printEEGSensorBytes() {
        print("========== EEG Data Start ==========")
        for (sensorIndex, packets) in eegSensorBytes.enumerated() {
            print("EEG \(sensorIndex + 1):")
            print(packets)
            print("")
        }
        print("========== EEG Data End ==========")
    }
    
    //MARK: - INIT -
    public init(deviceUUID: String? = nil) {
       
        if (deviceUUID == nil) {
            print("XvMuse: init with no deviceUUID")
        }
        
        var deviceCBUUID: CBUUID?
        if (deviceUUID != nil) {
            self.deviceUUID = deviceUUID
            deviceCBUUID = CBUUID(string: deviceUUID!)
        }
        
        _eeg = MuseEEG()
        _testEEG = MuseEEG()
     
        bluetooth = MuseBluetooth(deviceCBUUID: deviceCBUUID)
        bluetooth.delegate = self
        bluetooth.start()
        
        _parserAthena.delegate = self
    }
    
    //MARK: - Device API -
    public func lookForNearbyMuses(){
        if (debug) { print("XvMuse: lookForNearbyMuses") }
        deviceUUID = nil
        bluetooth.reset()
        bluetooth.connect()
    }
    
    public func didFindNearby(muses: [CBPeripheral]) {
        delegate?.didFindNearby(muses: muses)
    }
    
    public func userSelectedMuse(museDevice: CBPeripheral){
        if let museName = museDevice.name {
            let parts = museName.split(separator: "-")
            if let firstPart = parts.first {
                majorVersion = String(firstPart)
            } else {
                majorVersion = museName
            }
            if (majorVersion == "Muse") {
                deviceName = .muse1
            } else if (majorVersion == "MuseS") {
                deviceName = .museS
            }
            print("XvMuse: Major version =", majorVersion ?? "unknown", "| Device may be", deviceName ?? .unknown)
        }
        
        bluetooth.stop()
        bluetooth.load(muse: museDevice)
        processingQ.asyncAfter(deadline: .now() + 1) {
            self.bluetooth.connect()
        }
    }
    
    func discoveredPPG() {
        if (majorVersion == "Muse"){
            minorVersion = "2"
            deviceName = .muse2
        }
        print("XvMuse: Version:", majorVersion ?? "unknown", minorVersion ?? "unknown", "| Device", deviceName ?? .unknown)
    }
    
    func discoveredAthena() {
        minorVersion = "Athena"
        deviceName = .museAthena
        print("XvMuse: Version:", majorVersion ?? "unknown", minorVersion ?? "unknown", "| Device", deviceName ?? .unknown)
    }
    
    public func startMuse(){
        print("XvMuse: Start streaming Muse data")
        bluetooth.startStreaming()
    }
    
    //MARK: - DATA PROCESSING -
    internal func parse(bluetoothCharacteristic: CBCharacteristic) {
        
        processingQ.async { [weak self] in
            guard let self = self else { return }
            guard let _data: Data = bluetoothCharacteristic.value else { return }
            
            let timestamp: Double = Date().timeIntervalSince1970 - _systemLaunchTime
            
            if bluetoothCharacteristic.uuid == MuseConstants.CHAR_ATHENA_MAIN {
                let bytes = [UInt8](_data)
                self._parserAthena.parse(bytes: bytes, timestamp: timestamp)
                return
            }
        
            var bytes: [UInt8] = [UInt8](_data)
            let packetIndex: UInt16 = self._parserLegacy.getPacketIndex(fromBytes: bytes)
            bytes.removeFirst(2)
            
            func _makeEEGPacket(i: Int) -> MuseEEGPacket {
                return MuseEEGPacket(
                    packetIndex: packetIndex,
                    sensor: i,
                    timestamp: timestamp,
                    samples: self._parserLegacy.getEEGSamples(from: bytes))
            }
    
            switch bluetoothCharacteristic.uuid {
            
            //MARK: EEG
            case MuseConstants.CHAR_TP10:
                 self._eeg.update(withFFTResult: self._fft.process(eegPacket: _makeEEGPacket(i: 0)))
            case MuseConstants.CHAR_AF8:
                 self._eeg.update(withFFTResult: self._fft.process(eegPacket: _makeEEGPacket(i: 1)))
            case MuseConstants.CHAR_TP9:
                 self._eeg.update(withFFTResult: self._fft.process(eegPacket: _makeEEGPacket(i: 2)))
            case MuseConstants.CHAR_AF7:
                 self._eeg.update(withFFTResult: self._fft.process(eegPacket: _makeEEGPacket(i: 3)))
                 self.delegate?.didReceive(eegPacket: self.convert(museEEG: self._eeg))

            case MuseConstants.CHAR_CONTROL:
                if let commandResponse: [String: Any] = self._parserLegacy.parse(controlLine: bluetoothCharacteristic.value) {
                    var filtered = commandResponse
                    filtered.removeValue(forKey: "rc")
                    guard !filtered.isEmpty else { return }
                    print("XvMuse: commandResponse:", filtered)
                    self.delegate?.didReceive(commandResponse: filtered)
                }
                
            default:
                break
            }
        }
    }
    
    //MARK: - Athena
    func didReceiveAthenaEEGBuffers(
        packetIndex: UInt8,
        timestamp: TimeInterval,
        tp9: [Float],
        af7: [Float],
        af8: [Float],
        tp10: [Float]
    ) {
        let tp9D  = tp9.map { Double($0) }
        let af7D  = af7.map { Double($0) }
        let af8D  = af8.map { Double($0) }
        let tp10D = tp10.map { Double($0) }
        
        guard tp9D.count == af7D.count,
              tp9D.count == af8D.count,
              tp9D.count == tp10D.count,
              tp9D.count > 0 else {
            print("XvMuse: Error: Athena EEG buffers not the same size or empty")
            return
        }
        
        func makePacket(samples: [Double], sensor: Int) -> MuseEEGPacket {
            return MuseEEGPacket(
                packetIndex: UInt16(packetIndex),
                sensor: sensor,
                timestamp: timestamp,
                samples: samples
            )
        }
        
        _eeg.update(withFFTResult: _fft.process(eegPacket: makePacket(samples: tp9D,  sensor: 0)))
        _eeg.update(withFFTResult: _fft.process(eegPacket: makePacket(samples: af7D,  sensor: 1)))
        _eeg.update(withFFTResult: _fft.process(eegPacket: makePacket(samples: af8D,  sensor: 2)))
        _eeg.update(withFFTResult: _fft.process(eegPacket: makePacket(samples: tp10D, sensor: 3)))
        
        delegate?.didReceive(eegPacket: convert(museEEG: _eeg))
    }
    
    //MARK: - Test Data
    private let _testEEGData: [TestEEGData] = [
        TestEEGNoiseData(name: "Noise"),
        TestEEGStressData(name: "Stress"),
        TestEEGRestingFocusData(name: "Resting Focus"),
        TestEEGCodingData(name:"Coding"),
        TestEEGClearMindData(name:"Clear Mind"),
        TestEEGMeditationData(name: "Meditation"),
        TestEEGTiredData(name: "Tired"),
        TestEEGFallingAlseepData(name: "Falling Asleep")
    ]
    
    public func getTestEEGName(id: Int) -> String {
        var dataID: Int = id-1
        if (dataID >= _testEEGData.count) {
            dataID = _testEEGData.count-1
        }
        return _testEEGData[dataID].getName()
    }
    
    public func getTestEEG(id: Int) -> XvEEGPacket {
        var dataID: Int = id-1
        if (dataID >= _testEEGData.count) {
            dataID = _testEEGData.count-1
        }
        for i: Int in 0..<4 {
            let testEEGPacket: MuseEEGPacket = _testEEGData[dataID].getPacket(for: i)
            _testEEG.update(withFFTResult: _fft.process(eegPacket: testEEGPacket))
        }
        return convert(museEEG: _testEEG)
    }
    
    //MARK: - BLUETOOTH CONNECTION
    public var connected: Bool = false
    
    func isAttemptingConnection() { delegate?.museIsAttemptingConnection() }
    public func isConnecting() { delegate?.museIsConnecting() }
    
    public func didConnect() {
        connected = true
        processingQ.asyncAfter(deadline: .now() + 0.5) { self.bluetooth.versionHandshake() }
        processingQ.asyncAfter(deadline: .now() + 0.9) { [self] in
            if (deviceName == .museS) {
                print("XvMuse: Using MuseS preset 51")
                bluetooth.set(preset: MuseConstants.PRESET_51)
            } else if (deviceName == .museAthena) {
                print("XvMuse: Init Athena")
                bluetooth.athenaInitializeAndStart()
            }
        }
        processingQ.asyncAfter(deadline: .now() + 1.2) { self.bluetooth.controlStatus() }
        delegate?.museDidConnect()
    }
    
    public func didDisconnect() {
        connected = false
        delegate?.museDidDisconnect()
    }
    
    public func didLoseConnection() {
        connected = false
        delegate?.museLostConnection()
    }
    
    //MARK: - Thread -
    private let processingQ = DispatchQueue(label: "com.primaryassembly.xvmuse.processing", qos: .userInitiated)
    
    //MARK: - MOCK DATA -
    fileprivate var eegTestDataLoop: Timer = Timer()
    fileprivate var testDataSet: Int = 0
    
    internal func startTestData(set: Int){
        print("MuseHelper: startTestData: Set", set)
        testDataSet = set
        eegTestDataLoop.invalidate()
        eegTestDataLoop = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(generateTestEEGData), userInfo: nil, repeats: true)
    }
    
    @objc func generateTestEEGData() {
        delegate?.didReceive(eegPacket: getTestEEG(id: testDataSet))
    }
    
    internal func stopTestData(){
        eegTestDataLoop.invalidate()
    }
   
    //MARK: - Converters -
    private func convert(museEEG: MuseEEG) -> XvEEGPacket {
        return XvEEGPacket(
            sensors: [
                XvEEGSensorPacket(
                    area: XvEEGScalpLocation.TP.rawValue,
                    index: 9,
                    spectrum: _eeg.TP9.linearSpectrum
                ),
                XvEEGSensorPacket(
                    area: XvEEGScalpLocation.AF.rawValue,
                    index: 7,
                    spectrum: _eeg.AF7.linearSpectrum
                ),
                XvEEGSensorPacket(
                    area: XvEEGScalpLocation.AF.rawValue,
                    index: 8,
                    spectrum: museEEG.AF8.linearSpectrum
                ),
                XvEEGSensorPacket(
                    area: XvEEGScalpLocation.TP.rawValue,
                    index: 10,
                    spectrum: museEEG.TP10.linearSpectrum
                )
            ]
        )
    }
}
public enum XvDeviceName {
    case muse1
    case muse2
    case museS
    case museAthena
    case unknown
} 

//
//  MuseManager.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 26/04/2026.
//

import Foundation
import SwiftUI
import Combine
import CoreBluetooth // Required for the Bluetooth device discovery

class MuseManager: ObservableObject, XvMuseDelegate {
    static let shared = MuseManager() // Makes it accessible anywhere in your app
    
    @Published var isConnecting = false
    @Published var isConnected = false
    
    @Published var currentAlpha: Double = 0.0
    @Published var currentBeta: Double = 0.0
    @Published var currentState: String = "NEUTRAL"
    
    var muse: XvMuse
    
    private init() {
        self.muse = XvMuse()
        self.muse.delegate = self // Tell the headband to send data to THIS class
    }
    
    // MARK: - App Controls
    func connectHeadset() {
        print("Attempting to connect...")
        self.isConnecting = true
        // Step 1: Scan the room for the headband
        muse.lookForNearbyMuses()
    }
    
    func disconnectHeadset() {
            print("Disconnecting headset...")
            muse.bluetooth.disconnect()
        }
    
    func startStreamingData() {
        print("Starting stream...")
        // Step 3: Tell the headband to start sending the brainwaves
        muse.startMuse()
    }
    func pauseStreamingData() {
            print("Pausing EEG stream...")
            muse.bluetooth.pauseStreaming()
        }
    
    // MARK: - XvMuseDelegate Connection Protocol
    func museIsAttemptingConnection() { print("Muse is attempting connection...") }
    func museIsConnecting() { print("Muse is connecting...") }
    
    func didFindNearby(muses: [CBPeripheral]) {
        // Step 2: Automatically connect to the first Muse headband it finds!
        if let foundHeadband = muses.first {
            print("Found headband: \(foundHeadband.name ?? "Unknown"), locking in...")
            muse.userSelectedMuse(museDevice: foundHeadband)
        }
    }
    
    func museDidConnect() {
        DispatchQueue.main.async {
            self.isConnecting = false
            self.isConnected = true
            print("SUCCESS: Muse Connected! You can now start streaming.")
        }
    }
    
    func museDidDisconnect() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
        }
    }
    
    func museLostConnection() {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
        }
    }
    
    // MARK: - XvMuseDelegate Brainwave Data Protocol
    func didReceive(eegPacket: XvEEGPacket) {
        // This function fires constantly when streaming!
        DispatchQueue.main.async {
            // Grab the spectrum from the first sensor
            if let sensor = eegPacket.sensors.first {
                
                // Use the math engine to extract the specific Alpha and Beta waves
                let alpha = FrequencyManager.sharedInstance.getRelative(waveID: MuseConstants.WAVE_ID_ALPHA, spectrum: sensor.spectrum)
                let beta = FrequencyManager.sharedInstance.getRelative(waveID: MuseConstants.WAVE_ID_BETA, spectrum: sensor.spectrum)
                
                self.currentAlpha = alpha
                self.currentBeta = beta
                self.updateState()
            }
        }
    }
    
    func didReceive(commandResponse: [String : Any]) {
        // Just prints status updates from the headband (like battery warnings)
        print("Muse System Update: \(commandResponse)")
    }
    
    private func updateState() {
        // Your logic to determine stress levels
        if currentBeta > 0.7 { currentState = "STRESSED" }
        else if currentAlpha > 0.6 { currentState = "CALM" }
        else { currentState = "Neutral" }
    }
}


public struct XvEEGPacket {
    public var sensors: [XvEEGSensorPacket]
}

public struct XvEEGSensorPacket {
    public var area: String
    public var index: Int
    public var spectrum: [Double]
}

public enum XvEEGScalpLocation: String {
    case TP = "TP"
    case AF = "AF"
}

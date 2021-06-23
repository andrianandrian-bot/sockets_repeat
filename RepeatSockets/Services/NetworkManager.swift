//
//  NetworkManager.swift
//  RepeatSockets
//
//  Created by Andreas on 18.06.2021.
//

import Foundation
import SwiftProtobuf

class NetworkManager: NSObject {
    
    private let host: String
    private let port: Int
    private let messageFactory: MessageFactory
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    init(host: String, port: Int) {
        self.messageFactory = MessageFactory()
        self.host = host
        self.port = port
        super.init()
        openStream()
    }
    
    private func openStream() {
        guard inputStream == nil, outputStream == nil else { return }
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream.delegate = self
        
        inputStream.schedule(in: .main, forMode: .common)
        outputStream.schedule(in: .main, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    private func closeStream() {
        guard inputStream != nil, outputStream != nil else { return }
        
        inputStream.delegate = nil
        
        inputStream.remove(from: .main, forMode: .common)
        outputStream.remove(from: .main, forMode: .common)
        
        inputStream.close()
        outputStream.close()
    }
    
    private func reconnect() {
        closeStream()
        openStream()
    }
}

// MARK: - Stream Delegate

extension NetworkManager: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        guard let inputStream = inputStream else { return }
        
        switch eventCode {
        case .hasBytesAvailable:
            print("success")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard let self = self else { return }
                while inputStream.hasBytesAvailable {
                    self.readWrapperMessage(from: inputStream)
                }
            }
        default:
            print("something else")
        }
    }
    
    private func readWrapperMessage(from inputStream: InputStream) {
        
        do {
            let wrapperMessage = try BinaryDelimited.parse(messageType: AutoControl_Messenger_WrapperMessage.self,
                                                           from: inputStream)
            print("type is ", wrapperMessage.type)
            switch wrapperMessage.type {
            case .authorizationResponseType:
                if let data = try? AutoControl_Messenger_AuthorizationResponse(serializedData: wrapperMessage.data) {
                    print("State is ", data.state)
                }
            case .connectResponseType:
                if let data = try? AutoControl_Messenger_ConnectResponse(serializedData: wrapperMessage.data) {
                    print("Session ID os connection is ", data.sessionID)
                }
            case .vehicleConnectResponseType:
                if let data = try? AutoControl_Messenger_VehicleConnectResponse(serializedData: wrapperMessage.data) {
                    print("count of vehicles is ", data.data.count)
                } else {
                    print("error sss")
                }
            case .syncSensorDataResponseType:
                if let data = try? AutoControl_Messenger_SyncSensorDataResponse(serializedData: wrapperMessage.data) {
                    print("SENSORS ARE ", data)
                }
                
            case .syncBusResponseType:
                if let data = try? AutoControl_Messenger_SyncBusResponse(serializedData: wrapperMessage.data) {
                    print("BUS RESPONSE IS ", data)
                    print("BUSES COUNT IS ", data.bus.count)
                }
                
            case .navigationDataEventType:
                if let data = try? AutoControl_Messenger_NavigationDataEvent(serializedData: wrapperMessage.data) {
                    print("COURCE OF NAVIGATION IS ", data.data.course)
                }
                
            case .syncPointResponseType:
                if let data = try? AutoControl_Messenger_SyncPointResponse(serializedData: wrapperMessage.data) {
                    print("POINT RESPONSE COUNT IS  ", data.point.count)
                }
            case .syncNavigationDataResponseType:
                if let data = try? AutoControl_Messenger_SyncNavigationDataResponse(serializedData: wrapperMessage.data) {
                    print("SYNC NAVIGATION RESPONSE TYPE COUNT IS ", data.data.count)
                    
                } else {
                    print("ERROR!!!!")
                }
            default:
                print("default case")
            }
        } catch let error {
            print(error)
        }
    }
    
    private func sendWrapperMessage(message: Message) {
        guard
            let wrapperMessage = try? messageFactory.makeWrapperMessage(with: message),
            var data = try? wrapperMessage.serializedData()
        else { return }
        data.insert(UInt8(data.count), at: 0)
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
            else { return }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
}

extension NetworkManager {
    
    func authRequest(login: String, password: String) {
        sendWrapperMessage(message: messageFactory.makeAuthRequst(login: login, password: password))
    }
    
    func connectRequest() {
        sendWrapperMessage(message: messageFactory.makeConnectRequst())
    }
    
    func syncRequest() {
        sendWrapperMessage(message: messageFactory.makeSyncRequest())
    }
    
    func busRequest() {
        sendWrapperMessage(message: messageFactory.makeBusRequest())
    }
    
    func pointRequest() {
        sendWrapperMessage(message: messageFactory.makePointRequest())
    }
}

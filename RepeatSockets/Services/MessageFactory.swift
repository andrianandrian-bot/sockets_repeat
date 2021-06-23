//
//  MessageFactory.swift
//  RepeatSockets
//
//  Created by Andreas on 18.06.2021.
//

import Foundation
import SwiftProtobuf

class MessageFactory {
    
    let appVersion = "1.0.1"
    
    func makeWrapperMessage(with mesage: Message) throws -> AutoControl_Messenger_WrapperMessage {
        try AutoControl_Messenger_WrapperMessage.with {
            $0.type = type(of: mesage)
            $0.compressed = false
            $0.data = try mesage.serializedData()
            $0.seq = 111
        }
    }
    
    func makeSyncRequest() -> Message {
        AutoControl_Messenger_SyncRequest.with {
            $0.lastSyncTime = Int64(Date().timeIntervalSince1970)
        }
    }
    
    func makeAuthRequst(login: String, password: String) -> Message {
        AutoControl_Messenger_AuthorizationRequest.with {
            $0.login = login
            $0.password = password
        }
    }
    
    func makeConnectRequst() -> Message {
        AutoControl_Messenger_ConnectRequest.with {
            $0.clientType = 14
            $0.clientVersion = Data(appVersion.utf8)
            $0.protocol = 205
        }
    }
    
    func makeBusRequest() -> Message {
        AutoControl_Messenger_SyncBusRequest.with {
            $0.lastSyncTime = 1
        }
    }
    
    func makePointRequest() -> Message {
        AutoControl_Messenger_SyncPointRequest.with {
            $0.lastSyncTime = Int64(Date().timeIntervalSince1970)
        }
    }
    
//    func makeSyncGroupRequest() -> Message {
//        AutoControl_Messenger_SyncNavigationDataResponse
//    }
//    
    private func type(of message: Message) -> AutoControl_Messenger_Type {
        
        if message is AutoControl_Messenger_SyncRequest {
            return .syncRequestType
        }
        
        if message is AutoControl_Messenger_ConnectRequest {
            return .connectRequestType
        }
        
        if message is AutoControl_Messenger_AuthorizationRequest {
            return .authorizationRequestType
        }
        
        if message is AutoControl_Messenger_SyncBusRequest {
            return .syncBusRequestType
        }
        
        if message is AutoControl_Messenger_SyncPointRequest {
            return .syncPointRequestType
        }
        
        assertionFailure()
        return .connectRequestType
    }
}

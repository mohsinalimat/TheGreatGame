//
//  ComplicationPusher.swift
//  TheGreatGame
//
//  Created by Олег on 31.05.17.
//  Copyright © 2017 The Great Game. All rights reserved.
//

import Foundation
import Alba
import PushKit

public final class ComplicationPusher {
    
    public let didReceiveComplicationMatchUpdate = Publisher<Match.Full>(label: "ComplicationPusher.didReceiveComplicationMatchUpdate")
    
    public func declare(didReceiveIncomingPush: Subscribe<PKPushPayload>) {
        didReceiveIncomingPush
            .flatMap({ $0.dictionaryPayload as? [String : Any] })
            .flatMap({ try? PushNotification(from: $0) })
            .flatMap({ try? Match.Full(from: $0.content) })
            .redirect(to: didReceiveComplicationMatchUpdate)
    }
    
}

public final class PushKitReceiver : NSObject, PKPushRegistryDelegate {
    
    public let registry: PKPushRegistry
    
    public override init() {
        self.registry = PKPushRegistry(queue: nil)
        super.init()
        registry <- {
            $0.delegate = self
            $0.desiredPushTypes = [.complication]
        }
    }
    
    public let didRegisterWithToken = Publisher<String>(label: "PushKitReceiver.didRegisterWithToken")
    public let didReceiveIncomingPush = Publisher<PKPushPayload>(label: "PushKitReceiver.didReceiveIncomingPush")
    
}

extension PushKitReceiver {
    
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        let tokenString = credentials.token.reduce("", { $0 + String.init(format: "%02.2hhx", $1) })
        didRegisterWithToken.publish(tokenString)
    }
    
    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        didReceiveIncomingPush.publish(payload)
    }
    
}
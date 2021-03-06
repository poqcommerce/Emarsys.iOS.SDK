//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

import EmarsysSDK

@UIApplicationMain
class AppDelegate: EMSAppDelegate {

    override func provideEMSConfig() -> EMSConfig! {
        return EMSConfig.make { builder in
            builder.setMerchantId("1428C8EE286EC34B")
            builder.setContactFieldId(3)
            #if DEBUG
                builder.setMobileEngageApplicationCode("EMS11-C3FD3")
            #else
                builder.setMobileEngageApplicationCode("EMS4C-9A869")
            #endif
        }
    }

    override func handleEvent(_ eventName: String, payload: [String: NSObject]?) {
        super.handleEvent(eventName, payload: payload)
        print("EVENT_NAME: \(eventName), PAYLOAD: \(payload ?? [:])")
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        NotificationCenter.default.post(name: NotificationNames.pushTokenArrived.asNotificationName(), object: nil, userInfo: ["push_token": deviceToken])
    }
}

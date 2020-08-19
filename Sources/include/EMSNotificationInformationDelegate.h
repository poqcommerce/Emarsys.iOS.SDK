//
//  Copyright © 2020. Emarsys. All rights reserved.
//

#import <EmarsysSDK/EMSNotificationInformation.h>

@protocol EMSNotificationInformationDelegate <NSObject>

- (void)didReceiveNotificationInformation:(EMSNotificationInformation *)notificationInformation;

@end

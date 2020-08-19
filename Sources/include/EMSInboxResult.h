//
// Copyright (c) 2020 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSMessage.h>

@interface EMSInboxResult : NSObject

@property(nonatomic, strong) NSArray<EMSMessage *> *messages;

@end

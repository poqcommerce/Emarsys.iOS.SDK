//
// Copyright (c) 2018 Emarsys. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <EmarsysSDK/EMSInboxResult.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EMSCompletion)(void);

typedef void (^EMSCompletionBlock)(NSError *_Nullable error);

typedef void (^EMSSourceHandler)(NSString *source);

typedef void (^EMSInboxMessageResultBlock)(EMSInboxResult *_Nullable inboxResult, NSError *_Nullable error);

typedef void (^EMSEventHandler)(NSString *eventName, NSDictionary<NSString *, id> *_Nullable payload);

typedef void (^EMSInlineInappViewCloseBlock)(void);

NS_ASSUME_NONNULL_END
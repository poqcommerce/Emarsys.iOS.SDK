//
// Copyright (c) 2017 Emarsys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EMSAuthentication : NSObject

+ (NSString *)createBasicAuthWithUsername:(NSString *)username;
@end

NS_ASSUME_NONNULL_END
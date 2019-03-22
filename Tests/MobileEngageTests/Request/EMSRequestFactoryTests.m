//
//  Copyright © 2019 Emarsys. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "EMSRequestFactory.h"
#import "EMSUUIDProvider.h"
#import "EMSRequestModel.h"
#import "MERequestContext.h"
#import "EMSDeviceInfo.h"
#import "EMSDeviceInfo+MEClientPayload.h"
#import "NSDate+EMSCore.h"

@interface EMSRequestFactoryTests : XCTestCase
@property(nonatomic, strong) EMSRequestFactory *requestFactory;
@property(nonatomic, strong) MERequestContext *mockRequestContext;
@property(nonatomic, strong) EMSTimestampProvider *mockTimestampProvider;
@property(nonatomic, strong) EMSUUIDProvider *mockUUIDProvider;
@property(nonatomic, strong) EMSDeviceInfo *mockDeviceInfo;
@property(nonatomic, strong) EMSConfig *mockConfig;

@property(nonatomic, strong) NSDate *timestamp;
@end

@implementation EMSRequestFactoryTests

- (void)setUp {
    _mockRequestContext = OCMClassMock([MERequestContext class]);
    _mockTimestampProvider = OCMClassMock([EMSTimestampProvider class]);
    _mockUUIDProvider = OCMClassMock([EMSUUIDProvider class]);
    _mockDeviceInfo = OCMClassMock([EMSDeviceInfo class]);
    _mockConfig = OCMClassMock([EMSConfig class]);

    _timestamp = [NSDate date];

    OCMStub(self.mockRequestContext.timestampProvider).andReturn(self.mockTimestampProvider);
    OCMStub(self.mockRequestContext.deviceInfo).andReturn(self.mockDeviceInfo);
    OCMStub(self.mockRequestContext.config).andReturn(self.mockConfig);
    OCMStub(self.mockRequestContext.uuidProvider).andReturn(self.mockUUIDProvider);
    OCMStub(self.mockTimestampProvider.provideTimestamp).andReturn(self.timestamp);
    OCMStub(self.mockUUIDProvider.provideUUIDString).andReturn(@"requestId");
    OCMStub(self.mockDeviceInfo.hardwareId).andReturn(@"hardwareId");
    OCMStub(self.mockConfig.applicationCode).andReturn(@"testApplicationCode");

    _requestFactory = [[EMSRequestFactory alloc] initWithRequestContext:self.mockRequestContext];
}

- (void)testInit_requestContext_mustNotBeNil {
    @try {
        [[EMSRequestFactory alloc] initWithRequestContext:nil];
        XCTFail(@"Expected Exception when requestContext is nil!");
    } @catch (NSException *exception) {
        XCTAssertTrue([exception.reason isEqualToString:@"Invalid parameter not satisfying: requestContext"]);
    }
}

- (void)testCreateDeviceInfoRequestModel {
    NSDictionary *payload = @{
            @"platform": @"ios",
            @"applicationVersion": @"0.0.1",
            @"deviceModel": @"iPhone 6",
            @"osVersion": @"12.1",
            @"sdkVersion": @"0.0.1",
            @"language": @"en-US",
            @"timezone": @"+100"
    };
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/testApplicationCode/client"]
                                                                                method:@"POST"
                                                                               payload:payload
                                                                               headers:nil
                                                                                extras:nil];
    OCMStub(self.mockDeviceInfo.clientPayload).andReturn(payload);

    EMSRequestModel *requestModel = [self.requestFactory createDeviceInfoRequestModel];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

- (void)testCreatePushTokenRequestModelWithPushToken {
    NSString *const pushToken = @"awesdrxcftvgyhbj";
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/testApplicationCode/client/push-token"]
                                                                                method:@"PUT"
                                                                               payload:@{@"pushToken": pushToken}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createPushTokenRequestModelWithPushToken:pushToken];

    XCTAssertEqualObjects(expectedRequestModel, requestModel);
}

- (void)testCreateContactRequestModel {
    MEAppLoginParameters *appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:@3
                                                                                  contactFieldValue:@"test@test.com"];
    OCMStub([self.mockRequestContext appLoginParameters]).andReturn(appLoginParameters);

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/testApplicationCode/client/contact?anonymous=false"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"contactFieldId": @3,
                                                                                       @"contactFieldValue": @"test@test.com"
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateContactRequestModel_when_appLoginParametersIsNil {
    MEAppLoginParameters *appLoginParameters = nil;
    OCMStub([self.mockRequestContext appLoginParameters]).andReturn(appLoginParameters);

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/testApplicationCode/client/contact?anonymous=true"]
                                                                                method:@"POST"
                                                                               payload:@{}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateContactRequestModel_when_contactFieldValueIsNil {
    MEAppLoginParameters *appLoginParameters = [[MEAppLoginParameters alloc] initWithContactFieldId:@3
                                                                                  contactFieldValue:nil];
    OCMStub([self.mockRequestContext appLoginParameters]).andReturn(appLoginParameters);

    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://ems-me-client.herokuapp.com/v3/apps/testApplicationCode/client/contact?anonymous=true"]
                                                                                method:@"POST"
                                                                               payload:@{}
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createContactRequestModel];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateEventRequestModel_with_eventName_eventAttributes_internalType {
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/apps/testApplicationCode/client/events"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"clicks": @[],
                                                                                       @"viewedMessages": @[],
                                                                                       @"events": @[
                                                                                               @{
                                                                                                       @"type": @"internal",
                                                                                                       @"name": @"testEventName",
                                                                                                       @"timestamp": [self.timestamp stringValueInUTC],
                                                                                                       @"attributes":
                                                                                                       @{
                                                                                                               @"testEventAttributeKey1": @"testEventAttributeValue1",
                                                                                                               @"testEventAttributeKey2": @"testEventAttributeValue2"
                                                                                                       }
                                                                                               }
                                                                                       ]
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"testEventName"
                                                                              eventAttributes:@{
                                                                                      @"testEventAttributeKey1": @"testEventAttributeValue1",
                                                                                      @"testEventAttributeKey2": @"testEventAttributeValue2"
                                                                              }
                                                                                    eventType:EventTypeInternal];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

- (void)testCreateEventRequestModel_with_eventName_customType {
    EMSRequestModel *expectedRequestModel = [[EMSRequestModel alloc] initWithRequestId:@"requestId"
                                                                             timestamp:self.timestamp
                                                                                expiry:FLT_MAX
                                                                                   url:[[NSURL alloc] initWithString:@"https://mobile-events.eservice.emarsys.net/v3/apps/testApplicationCode/client/events"]
                                                                                method:@"POST"
                                                                               payload:@{
                                                                                       @"clicks": @[],
                                                                                       @"viewedMessages": @[],
                                                                                       @"events": @[
                                                                                               @{
                                                                                                       @"type": @"custom",
                                                                                                       @"name": @"testEventName",
                                                                                                       @"timestamp": [self.timestamp stringValueInUTC]
                                                                                               }
                                                                                       ]
                                                                               }
                                                                               headers:nil
                                                                                extras:nil];

    EMSRequestModel *requestModel = [self.requestFactory createEventRequestModelWithEventName:@"testEventName"
                                                                              eventAttributes:nil
                                                                                    eventType:EventTypeCustom];

    XCTAssertEqualObjects(requestModel, expectedRequestModel);
}

@end
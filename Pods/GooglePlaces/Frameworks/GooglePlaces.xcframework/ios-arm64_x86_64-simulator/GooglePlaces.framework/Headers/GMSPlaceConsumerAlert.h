//
//  GMSPlaceConsumerAlert.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GMSPlaceConsumerAlertDetails;

/**
 * The consumer alert message for the place when we detect suspicious review activity on a business
 * or a business violates our policies.
 */
@interface GMSPlaceConsumerAlert : NSObject

/** The overview of the consumer alert. */
@property(nonatomic, copy, readonly, nullable) NSString *overview;

/** The details of the consumer alert. */
@property(nonatomic, copy, readonly, nullable) GMSPlaceConsumerAlertDetails *details;

/** The language code of the consumer alert. This is a BCP 47 language code. */
@property(nonatomic, copy, readonly, nullable) NSString *languageCode;

- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END

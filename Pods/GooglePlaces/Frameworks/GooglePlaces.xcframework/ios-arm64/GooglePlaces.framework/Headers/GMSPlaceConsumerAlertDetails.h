//
//  GMSPlaceConsumerAlertDetails.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** The details of the consumer alert message. */
@interface GMSPlaceConsumerAlertDetails : NSObject

/** The title of the consumer alert. */
@property(nonatomic, copy, readonly, nullable) NSString *title;

/** The description of the consumer alert. */
@property(nonatomic, copy, readonly, nullable) NSString *alertDescription;

/** The title of the about link. */
@property(nonatomic, copy, readonly, nullable) NSString *aboutLinkTitle;

/** The URI of the about link. */
@property(nonatomic, copy, readonly, nullable) NSURL *aboutLinkURI;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

//
//  GMSPlaceRoutingSummary.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


@class GMSPlaceLeg;

NS_ASSUME_NONNULL_BEGIN

/**
 *  The duration and distance from the routing origin to a place in the response, and a second leg
 *  from that place to the destination, if requested.
 */
@interface GMSPlaceRoutingSummary : NSObject

/** A leg is a single portion of a trip from one location to another. */
@property(nonatomic, copy, readonly, nullable) NSArray<GMSPlaceLeg *> *legs;

/** A link to show directions on Google Maps for the given routing summary. */
@property(nonatomic, readonly, nullable) NSURL *directionsURL;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


//
//  GMSPlaceLeg.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/** A single portion of a trip from one location to another. */
@interface GMSPlaceLeg : NSObject

/** The time it takes to finish this leg of the trip. */
@property(nonatomic, readonly) NSTimeInterval duration;

/** The distance of this leg of the trip. */
@property(nonatomic, readonly) NSUInteger distanceMeters;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


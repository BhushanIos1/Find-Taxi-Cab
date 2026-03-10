//
//  GMSPlaceEncodedPolyline.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protocols

/** Protocol for specifying a route polyline. */
@protocol GMSPlacePolyline <NSObject, NSCopying>
@end

/**
 * An encoded polyline for a route.
 *
 * See https://developers.google.com/maps/documentation/utilities/polylinealgorithm for more
 * info.
 */
@interface GMSPlaceEncodedPolyline : NSObject <GMSPlacePolyline>

/** The encoded polyline to represent a route. */
@property(nonatomic, readonly) NSString *encodedPolyline;

/**
 * Returns instance of `GMSPlaceEncodedPolyline`.
 *
 * @param encodedPolyline The encoded polyline raw string.
 * @return The encoded polyline object.
 */
- (instancetype)initWithEncodedPolyline:(NSString *)encodedPolyline NS_DESIGNATED_INITIALIZER;

/** Default init is not available. Please use the designated initializer. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


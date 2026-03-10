//
//  GMSPlaceSearchAlongRouteParameters.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


@protocol GMSPlacePolyline;

NS_ASSUME_NONNULL_BEGIN

/** Additional parameters for searching along a route. */
@interface GMSPlaceSearchAlongRouteParameters : NSObject

/**
 * The polyline defining the route to search along.
 */
@property(nonatomic, readonly) id<GMSPlacePolyline> polyline;

/**
 * Initializes the `GMSPlaceSearchAlongRouteParameters` with the given `polyline`.
 *
 * @param polyline The polyline defining the route to search along.
 */
- (instancetype)initWithPolyline:(id<GMSPlacePolyline>)polyline NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


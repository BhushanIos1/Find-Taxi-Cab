//
//  GMSPlaceRouteModifiers.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/** Encapsulates a set of optional conditions to satisfy when calculating the routes. */
@interface GMSPlaceRouteModifiers : NSObject
/**
 * When set to true, avoids toll roads where reasonable, giving preference to routes not containing
 * toll roads. Applies only to the `Drive` and `TwoWheeler` travel modes.
 *
 * Default value is false.
 */
@property(nonatomic) BOOL avoidTolls;

/**
 * When set to true, avoids highways where reasonable, giving preference to routes not containing
 * highways. Applies only to the `Drive` and `TwoWheeler` travel modes.
 *
 * Default value is false.
 */
@property(nonatomic) BOOL avoidHighways;

/**
 * When set to true, avoids ferries where reasonable, giving preference to routes not containing
 * ferries. Applies only to the `Drive` and `TwoWheeler` travel modes.
 *
 * Default value is false.
 */
@property(nonatomic) BOOL avoidFerries;

/**
 * When set to true, avoids navigating indoors where reasonable, giving preference to routes not
 * containing indoor navigation. Applies only to the `Walk` travel modes.
 *
 * Default value is false.
 */
@property(nonatomic) BOOL avoidIndoor;

- (instancetype)initWithAvoidTolls:(BOOL)avoidTolls
                     avoidHighways:(BOOL)avoidHighways
                      avoidFerries:(BOOL)avoidFerries
                       avoidIndoor:(BOOL)avoidIndoor;

@end

NS_ASSUME_NONNULL_END


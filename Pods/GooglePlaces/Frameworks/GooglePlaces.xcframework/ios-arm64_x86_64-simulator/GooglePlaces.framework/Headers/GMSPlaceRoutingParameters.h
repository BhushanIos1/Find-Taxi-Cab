//
//  GMSPlaceRoutingParameters.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class GMSPlaceRouteModifiers;

/** Travel mode options. */
typedef NS_ENUM(NSInteger, GMSPlaceTravelMode) {
  /** The travel mode is not specified. */
  GMSPlaceTravelModeUnspecified,

  /** The travel mode is driving. */
  GMSPlaceTravelModeDrive,

  /**
   * If using {@link GMSPlaceSearchAlongRouteParameters}, this mode is not supported.
   */
  GMSPlaceTravelModeBicycle,

  /**
   * If using {@link GMSPlaceSearchAlongRouteParameters}, this mode is not supported.
   */
  GMSPlaceTravelModeWalk,

  /**
   * If using {@link GMSPlaceSearchAlongRouteParameters}, this mode is not supported.
   *
   * Only supported in those countries listed at
   * https://developers.google.com/maps/documentation/routes/coverage-two-wheeled
   */
  GMSPlaceTravelModeTwoWheeler,
};

/** A set of values that specify factors to take into consideration when calculating the routes. */
typedef NS_ENUM(NSInteger, GMSPlaceRoutingPreference) {
  /** No routing preference specified. Default to `TrafficUnaware`. */
  GMSPlaceRoutingPreferenceUnspecified,

  /**
   * Computes routes without taking live traffic conditions into consideration.
   *
   * Suitable when
   * traffic conditions don't matter or are not applicable. Using this value produces the lowest
   * latency.
   *
   * Important note when using the DRIVE and TWO_WHEELER travel modes that are specified in
   * {@link GMSPlaceTravelMode}. The route
   * and duration chosen are based on road network and average time-independent traffic
   * conditions, not current road conditions. Consequently, routes may include roads that are
   * temporarily closed. Results for a given request may vary over time due to changes in the road
   * network, updated average traffic conditions, and the distributed nature of the service.
   * Results may also vary between nearly-equivalent routes at any time or frequency.
   */
  GMSPlaceRoutingPreferenceTrafficUnaware,

  /**
   * Calculates routes taking live traffic conditions into consideration. In contrast to
   * `TrafficAwareOptimal`, some optimizations are applied to significantly reduce latency.
   */
  GMSPlaceRoutingPreferenceTrafficAware,

  /**
   * Calculates the routes taking live traffic conditions into consideration, without applying most
   * performance optimizations. Using this value produces the highest latency.
   */
  GMSPlaceRoutingPreferenceTrafficAwareOptimal,
};

/**
 * Parameters to configure the routing calculations to the places in the response, both along a
 * route (where result ranking will be influenced) and for calculating travel times on results.
 */
@interface GMSPlaceRoutingParameters : NSObject

/**
 * An explicit routing origin that overrides the origin defined in the polyline. By default, the
 * polyline origin is used.
 */
@property(nonatomic, readonly, assign) CLLocationCoordinate2D origin;

/** The travel mode. */
@property(nonatomic, readonly) GMSPlaceTravelMode travelMode;

/** The route modifiers. */
@property(nonatomic, readonly, nullable) GMSPlaceRouteModifiers *routeModifiers;

/**
 * The routing preference specifies factors to take into consideration when calculating the route.
 */
@property(nonatomic, readonly) GMSPlaceRoutingPreference routingPreference;

/**
 * Inits the routing parameters.
 *
 * @param travelMode The travel mode.
 * @param routeModifiers The route modifiers.
 * @param routingPreference The routing preference.
 */
- (instancetype)initWithTravelMode:(GMSPlaceTravelMode)travelMode
                    routeModifiers:(nullable GMSPlaceRouteModifiers *)routeModifiers
                 routingPreference:(GMSPlaceRoutingPreference)routingPreference;

/**
 * Inits the routing parameters.
 *
 * @param origin The origin.
 * @param travelMode The travel mode.
 * @param routeModifiers The route modifiers.
 * @param routingPreference The routing preference.
 */
- (instancetype)initWithOrigin:(CLLocationCoordinate2D)origin
                    travelMode:(GMSPlaceTravelMode)travelMode
                routeModifiers:(nullable GMSPlaceRouteModifiers *)routeModifiers
             routingPreference:(GMSPlaceRoutingPreference)routingPreference
    NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


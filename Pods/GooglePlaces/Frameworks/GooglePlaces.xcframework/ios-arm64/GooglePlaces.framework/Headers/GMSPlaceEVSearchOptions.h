//
//  GMSPlaceEVSearchOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GMSPlaceEVConnectorType);

/** Searchable EV options of a place search request. */
@interface GMSPlaceEVSearchOptions : NSObject

/**
 * Minimum required charging rate in kilowatts. A place with a charging rate less than the specified
 * rate is filtered out.
 */
@property(nonatomic, readonly) double minimumChargingRateKW;

/**
 * The list of preferred EV connector types. A place that does not support any of the listed
 * connector types is filtered out.
 * `connectorTypes` needs to be an array of `GMSPlaceEVConnectorType`, which can be found in
 * `GMSPlaceConnectorAggregation.h`
 */
@property(nonatomic, copy, readonly, nullable) NSArray<NSNumber *> *connectorTypes;

/**
 * Initializes a new instance of `GMSPlaceEVSearchOptions`.
 *
 * @param minimumChargingRateKW The minimum charging rate of the EV charging connector in
 * kilowatts.
 * @param connectorTypes The list of preferred EV connector types.
 */
- (instancetype)initWithMinimumChargingRateKW:(double)minimumChargingRateKW
                               connectorTypes:(nullable NSArray<NSNumber *> *)connectorTypes
    NS_DESIGNATED_INITIALIZER;

/** Default init is not available. Please use the designated initializer. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


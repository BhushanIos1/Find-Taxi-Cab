//
//  GMSPlaceEVChargeOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

@class GMPSV1EVChargeOptions_ConnectorAggregation;
@class GMSPlaceConnectorAggregation;

NS_ASSUME_NONNULL_BEGIN

/** A class that represents a place's EV charging options. */
@interface GMSPlaceEVChargeOptions : NSObject

/** The total number of charging connector aggregations available. */
@property(nonatomic, readonly) NSInteger connectorCount;

/** The array of charging connector aggregations. */
@property(nonatomic, copy, readonly, nullable)
    NSArray<GMSPlaceConnectorAggregation *> *connectorAggregations;

@end

NS_ASSUME_NONNULL_END

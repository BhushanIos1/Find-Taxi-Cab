//
//  GMSPlaceConnectorAggregation.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Describes the EV charging connector type. */
typedef NS_ENUM(NSInteger, GMSPlaceEVConnectorType) {
  GMSPlaceEVConnectorTypeUnspecified = 0,
  GMSPlaceEVConnectorTypeJ1772 = 1,
  GMSPlaceEVConnectorTypeType2 = 2,
  GMSPlaceEVConnectorTypeCHADeMO = 3,
  GMSPlaceEVConnectorTypeCCSCombo1 = 4,
  GMSPlaceEVConnectorTypeCCSCombo2 = 5,
  GMSPlaceEVConnectorTypeNACS = 6,
  GMSPlaceEVConnectorTypeTesla = 7,
  GMSPlaceEVConnectorTypeUnspecifiedGBT = 8,
  GMSPlaceEVConnectorTypeUnspecifiedWallOutlet = 9,
  GMSPlaceEVConnectorTypeOther = 10,
};

/** A class that represents an EV charging connector aggregation. */
@interface GMSPlaceConnectorAggregation : NSObject

/** The type of the EV charging connector. */
@property(nonatomic, readonly) GMSPlaceEVConnectorType type;

/** The max charge rate of the EV charging connector in kilowatts. */
@property(nonatomic, readonly) double maxChargeRateKW;

/** The number of EV charging connectors. */
@property(nonatomic, readonly) NSUInteger count;

/** The number of available EV charging connectors. */
@property(nonatomic, readonly) NSUInteger availableCount;

/** The number of out of service EV charging connectors. */
@property(nonatomic, readonly) NSUInteger outOfServiceCount;

/** The time that the availability of the EV charging connector was updated. */
@property(nonatomic, copy, readonly, nullable) NSDate *availabilityLastUpdateTime;

@end

NS_ASSUME_NONNULL_END

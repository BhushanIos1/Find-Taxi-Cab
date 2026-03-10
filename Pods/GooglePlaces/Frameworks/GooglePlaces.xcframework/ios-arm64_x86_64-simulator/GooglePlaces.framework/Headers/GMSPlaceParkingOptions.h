//
//  GMSPlaceParkingOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2023 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>
#import "GMSPlace.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class represents the parking options for a place.
 */
@interface GMSPlaceParkingOptions : NSObject

/** Place Attribute for free parking lot. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute freeParkingLot;

/** Place Attribute for paid parking lot. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute paidParkingLot;

/** Place Attribute for free street parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute freeStreetParking;

/** Place Attribute for paid street parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute paidStreetParking;

/** Place Attribute for free garage parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute freeGarageParking;

/** Place Attribute for paid garage parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute paidGarageParking;

/** Place Attribute for valet parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute valetParking;
@end

NS_ASSUME_NONNULL_END

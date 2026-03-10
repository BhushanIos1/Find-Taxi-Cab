//
//  GMSPlaceAccessibilityOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>


#import "GMSPlace.h"

NS_ASSUME_NONNULL_BEGIN

/** Information about the accessibility options a place offers. */
@interface GMSPlaceAccessibilityOptions : NSObject

/** Returns the `GMSBooleanPlaceAttribute` for a wheelchair accessible parking. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute wheelchairAccessibleParking;

/** Returns the `GMSBooleanPlaceAttribute` for a wheelchair accessible entrance. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute wheelchairAccessibleEntrance;

/** Returns the `GMSBooleanPlaceAttribute` for a wheelchair accessible restroom. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute wheelchairAccessibleRestroom;

/** Returns the `GMSBooleanPlaceAttribute` for a wheelchair accessible seating. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute wheelchairAccessibleSeating;
@end

NS_ASSUME_NONNULL_END


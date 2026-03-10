//
//  GMSPlaceFuelOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>



@class GMSPlaceFuelPrice;

NS_ASSUME_NONNULL_BEGIN

/** The most recent information about fuel options in a gas station. */
@interface GMSPlaceFuelOptions : NSObject

/** The last known fuel price for each type of fuel this station has. */
@property(nonatomic, readonly) NSArray<GMSPlaceFuelPrice *> *fuelPrices;

@end

NS_ASSUME_NONNULL_END


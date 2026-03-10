//
//  GMSPlaceEVChargeAmenitySummary.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

#import "GMSPlaceAISummary.h"

@class GMSPlaceContentBlock;

NS_ASSUME_NONNULL_BEGIN

/**
 * The summary of amenities near the EV charging station. This only applies to places with type
 * "electric_vehicle_charging_station".
 */
@interface GMSPlaceEVChargeAmenitySummary : NSObject <GMSPlaceAISummary>

/** Returns an overview of the available amenities. */
@property(nonatomic, copy, readonly, nullable) GMSPlaceContentBlock *overview;

/** Returns a summary of the nearby coffee options. */
@property(nonatomic, copy, readonly, nullable) GMSPlaceContentBlock *coffee;

/** Returns a summary of the nearby restaurants. */
@property(nonatomic, copy, readonly, nullable) GMSPlaceContentBlock *restaurant;

/** Returns a summary of the nearby stores. */
@property(nonatomic, copy, readonly, nullable) GMSPlaceContentBlock *store;

/** Returns the URI to flag a problem with the summary. */
@property(nonatomic, copy, readonly, nullable) NSURL *flagContentURI;

/** Returns the AI disclosure message "Summarized with Gemini". */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureText;

/** Returns the disclosure text's language code, if available. */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureTextLanguageCode;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

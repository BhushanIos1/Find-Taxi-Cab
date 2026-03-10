//
//  GMSPlaceSearchByTextRankPreference.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * \defgroup PlaceSearchByTextRankPreference GMSPlaceSearchByTextRankPreference
 * @{
 */

/** How results will be ranked in the response. */
typedef NS_ENUM(NSInteger, GMSPlaceSearchByTextRankPreference) {
  GMSPlaceSearchByTextRankPreferenceDistance,
  GMSPlaceSearchByTextRankPreferenceRelevance
};

NS_ASSUME_NONNULL_END

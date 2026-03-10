//
//  GMSPlaceSearchNearbyRankPreference.h
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
 * \defgroup PlaceSearchNearbyRankPreference GMSPlaceSearchNearbyRankPreference
 * @{
 */

/** How results will be ranked in the response. */
typedef NS_ENUM(NSInteger, GMSPlaceSearchNearbyRankPreference) {
  /** (default) Sorts results based on their popularity. */
  GMSPlaceSearchNearbyRankPreferencePopularity,
  /** Sorts results in ascending order by their distance from the specified location. */
  GMSPlaceSearchNearbyRankPreferenceDistance,
};

NS_ASSUME_NONNULL_END

//
//  GMSPlacesAutocompleteTypeFilter.h
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
 * \defgroup PlacesAutocompleteTypeFilter GMSPlacesAutocompleteTypeFilter
 * @{
 */

/**
 * The type filters that may be applied to an autocomplete request to restrict results to different
 * types.
 */
typedef NS_ENUM(NSInteger, GMSPlacesAutocompleteTypeFilter) {
  /** All results. */
  kGMSPlacesAutocompleteTypeFilterNoFilter,

  /** Geocoding results, as opposed to business results. */
  kGMSPlacesAutocompleteTypeFilterGeocode,

  /** Geocoding results with a precise address. */
  kGMSPlacesAutocompleteTypeFilterAddress,

  /** Business results. */
  kGMSPlacesAutocompleteTypeFilterEstablishment,

  /**
   * Results that match the following types:
   * "locality",
   * "sublocality"
   * "postal_code",
   * "country",
   * "administrative_area_level_1",
   * "administrative_area_level_2"
   */
  kGMSPlacesAutocompleteTypeFilterRegion,

  /**
   * Results that match the following types:
   * "locality",
   * "administrative_area_level_3"
   */
  kGMSPlacesAutocompleteTypeFilterCity,
};

/**@}*/

NS_ASSUME_NONNULL_END

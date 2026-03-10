//
//  GMSPlaceSearchByTextResponse.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>

#import "GMSPlace.h"
#import "GMSPlaceSearchResponse.h"

@class GMSPlacePagination;

NS_ASSUME_NONNULL_BEGIN

/** The response object for the `searchByText` method. */
@interface GMSPlaceSearchByTextResponse : NSObject <GMSPlaceSearchResponse>

/** The array of places that match the request. */
@property(readonly, nonatomic, copy, nullable) NSArray<GMSPlace *> *places;

/** The pagination object for the response. */
@property(readonly, nonatomic, nullable) GMSPlacePagination *pagination;

/**
 * A list of routing summaries where each entry associates to the corresponding place in the same
 * index in the places field.
 */
@property(readonly, nonatomic, nullable) NSArray<GMSPlaceRoutingSummary *> *routingSummaries;

/** A link to search with the given query on Google Maps. */
@property(readonly, nonatomic, nullable) NSURL *searchURL;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

//
//  GMSPlacePagination.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>

@protocol GMSPlaceSearchResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 * Pagination object for {@link GMSPlaceSearchResponse}. There could be more than one page of
 * results in a single search, use {@link fetchNextPageWithCompletion} to fetch the next page of
 * results.
 */
@interface GMSPlacePagination : NSObject

/**
 * Returns whether there is a next page of results.
 */
@property(nonatomic, readonly) BOOL hasNextPage;

/**
 * The number of results in the next page of results.
 */
@property(nonatomic) NSInteger pageSize;

/**
 * Fetches the next page of results.
 *
 * @param completion The completion block to be called when the next page of results is fetched.
 *                   The completion block takes two parameters:
 *                   - response: The {@link GMSPlaceSearchResponse} object containing the next
 *                              page of results.
 *                   - error: The error object if the fetch fails.
 */
- (void)fetchNextPageWithCompletion:(void (^)(id<GMSPlaceSearchResponse> _Nullable response,
                                              NSError *_Nullable error))completion;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

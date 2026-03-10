//
//  GMSPlaceGoogleMapsLinks.h
//  Google Places SDK for iOS
//
//  Copyright 2026 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/** Links to trigger different Google Maps actions for a place. */
@interface GMSPlaceGoogleMapsLinks : NSObject

/**
 * Returns a link to show the directions to the place. The link only populates the destination
 * location and uses the default travel mode `DRIVE`.
 */
@property(nonatomic, readonly, nullable) NSURL *directionsURL;

/** Returns a link to show this place. */
@property(nonatomic, readonly, nullable) NSURL *placeURL;

/** Returns a link to write a review for this place. */
@property(nonatomic, readonly, nullable) NSURL *writeAReviewURL;

/** Returns a link to show reviews of this place. */
@property(nonatomic, readonly, nullable) NSURL *reviewsURL;

/** Returns a link to show photos of this place. */
@property(nonatomic, readonly, nullable) NSURL *photosURL;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


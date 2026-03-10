//
//  GMSPlaceContentBlock.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** A class that represents a content block. */
@interface GMSPlaceContentBlock : NSObject

/** The content of the content block. */
@property(nonatomic, copy, readonly, nullable) NSString *content;

/** The text's BCP-47 language code, such as "en-US" or "sr-Latn". */
@property(nonatomic, copy, readonly, nullable) NSString *contentLanguageCode;

/**
 * The list of resource names of the referenced places. These names can be used
 * in other APIs that accept Place resource names.
 */
@property(nonatomic, copy, readonly, nullable) NSArray<NSString *> *referencedPlaceResourceNames;

/**
 * The list of place IDs of the referenced places. These IDs can be used
 * in other APIs that accept Place IDs.
 */
@property(nonatomic, copy, readonly, nullable) NSArray<NSString *> *referencedPlaceIDs;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

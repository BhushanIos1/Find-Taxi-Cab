//
//  GMSPlaceReviewSummary.h
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

/** AI-generated summary of the place using user reviews. */
@interface GMSPlaceReviewSummary : NSObject <GMSPlaceAISummary>

/** The summary of user reviews. */
@property(nonatomic, copy, readonly, nullable) NSString *text;

/** The language code of the summary, if available. */
@property(nonatomic, copy, readonly, nullable) NSString *textLanguageCode;

/** A link where users can flag a problem with the summary. */
@property(nonatomic, copy, readonly, nullable) NSURL *flagContentURI;

/**
 * The AI disclosure message "Summarized with Gemini" (and its localized variants). This will be in
 * the language specified in the request if available.
 */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureText;

/** The language code for the disclosure text. */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureTextLanguageCode;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

//
//  GMSPlaceGenerativeSummary.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

#import "GMSPlaceAISummary.h"

NS_ASSUME_NONNULL_BEGIN

/** A class that represents a place's generative summary. */
@interface GMSPlaceGenerativeSummary : NSObject <GMSPlaceAISummary>

/** Localized string describing the overview of the place. */
@property(nonatomic, copy, readonly, nullable) NSString *overview;

/**
 * The text's BCP-47 language code, such as "en-US" or "sr-Latn".
 *
 * For more information, see
 * http://www.unicode.org/reports/tr35/#Unicode_locale_identifier.
 */
@property(nonatomic, copy, readonly, nullable) NSString *overviewLanguageCode;

/** A link where users can flag a problem with the overview summary. */
@property(nonatomic, copy, readonly, nullable) NSURL *flagContentURI;

/**
 * The AI disclosure message "Summarized with Gemini" (and its localized variants).
 */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureText;

/**
 * The text's BCP-47 language code, such as "en-US" or "sr-Latn".
 *
 * For more information, see
 * http://www.unicode.org/reports/tr35/#Unicode_locale_identifier.
 */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureTextLanguageCode;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

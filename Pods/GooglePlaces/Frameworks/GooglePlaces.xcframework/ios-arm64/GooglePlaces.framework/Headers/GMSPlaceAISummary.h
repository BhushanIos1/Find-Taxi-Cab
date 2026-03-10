//
//  GMSPlaceAISummary.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>

/**
 * Protocol for the AI-generated summary of the place.
 */
@protocol GMSPlaceAISummary <NSObject>

/** Returns the URI to flag a problem with the summary. */
@property(nonatomic, copy, readonly, nullable) NSURL *flagContentURI;

/** Returns the AI disclosure message "Summarized with Gemini". */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureText;

/** Returns the disclosure text's language code, if available. */
@property(nonatomic, copy, readonly, nullable) NSString *disclosureTextLanguageCode;

@end

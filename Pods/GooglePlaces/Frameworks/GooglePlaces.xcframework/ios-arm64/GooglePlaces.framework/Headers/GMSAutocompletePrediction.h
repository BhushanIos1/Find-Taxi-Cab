//
//  GMSAutocompletePrediction.h
//  Google Places SDK for iOS
//
//  Copyright 2016 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>

#import "GMSPlacesDeprecationUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Attribute name for match fragments in `GMSAutocompletePrediction` attributedFullText.
 *
 * @see `GMSAutocompletePrediction`
 */
__GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
extern NSAttributedStringKey const kGMSAutocompleteMatchAttribute;

/** This class represents a prediction of a full query based on a partially typed string. */
__GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
@interface GMSAutocompletePrediction : NSObject

/**
 * The full description of the prediction as a NSAttributedString. E.g., "Sydney Opera House,
 * Sydney, New South Wales, Australia".
 *
 * Every text range that matches the user input has a `kGMSAutocompleteMatchAttribute`.  For
 * example, you can make every match bold using enumerateAttribute:
 * <pre>
 *   UIFont *regularFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
 *   UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
 *
 *   NSMutableAttributedString *bolded = [prediction.attributedFullText mutableCopy];
 *   [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
 *                      inRange:NSMakeRange(0, bolded.length)
 *                      options:0
 *                   usingBlock:^(id value, NSRange range, BOOL *stop) {
 *                     UIFont *font = (value == nil) ? regularFont : boldFont;
 *                     [bolded addAttribute:NSFontAttributeName value:font range:range];
 *                   }];
 *
 *   label.attributedText = bolded;
 * </pre>
 */
@property(nonatomic, copy, readonly) NSAttributedString *attributedFullText
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/**
 * The main text of a prediction as a NSAttributedString, usually the name of the place.
 * E.g. "Sydney Opera House".
 *
 * Text ranges that match user input are have a `kGMSAutocompleteMatchAttribute`,
 * like `attributedFullText`.
 */
@property(nonatomic, copy, readonly) NSAttributedString *attributedPrimaryText
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/**
 * The secondary text of a prediction as a NSAttributedString, usually the location of the place.
 * E.g. "Sydney, New South Wales, Australia".
 *
 * Text ranges that match user input are have a `kGMSAutocompleteMatchAttribute`, like
 * `attributedFullText`.
 *
 * May be nil.
 */
@property(nonatomic, copy, readonly, nullable) NSAttributedString *attributedSecondaryText
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/**
 * A property representing the place ID of the prediction, suitable for use in a place details
 * request.
 */
@property(nonatomic, copy, readonly) NSString *placeID
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/**
 * The types of this autocomplete result.  Types are NSStrings, valid values are any types
 * documented at <https://developers.google.com/places/ios-sdk/supported_types>.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *types
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/**
 * The straight line distance in meters between the origin and this prediction if a valid origin is
 * specified in the `GMSAutocompleteFilter` of the request.
 */
@property(nonatomic, readonly, nullable) NSNumber *distanceMeters
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

/** Initializer is not available. */
- (instancetype)init NS_UNAVAILABLE
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG("Use <code>GMSAutocompleteSuggestion</code> instead.")
        ;

@end

NS_ASSUME_NONNULL_END

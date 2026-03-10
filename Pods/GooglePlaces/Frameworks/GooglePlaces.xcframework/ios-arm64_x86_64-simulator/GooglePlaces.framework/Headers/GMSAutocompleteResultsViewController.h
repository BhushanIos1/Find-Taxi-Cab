//
//  GMSAutocompleteResultsViewController.h
//  Google Places SDK for iOS
//
//  Copyright 2016 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <UIKit/UIKit.h>

#import "GMSPlaceFieldMask.h"
#import "GMSPlaceProperty.h"
#import "GMSPlacesDeprecationUtils.h"

@class GMSAutocompleteFilter;
@class GMSAutocompletePrediction;
@class GMSAutocompleteResultsViewController;
@class GMSPlace;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol used by `GMSAutocompleteResultsViewController`, to communicate the user's interaction
 * with the controller to the application.
 */
__GMS_AVAILABLE_BUT_DEPRECATED_MSG(
    "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
    "(https://developers.google.com/maps/documentation/places/"
    "ios-sdk/google-places-swift) instead.")
@protocol GMSAutocompleteResultsViewControllerDelegate <NSObject>

@required

/**
 * Called when a place has been selected from the available autocomplete predictions.
 * @param resultsController The `GMSAutocompleteResultsViewController` that generated the event.
 * @param place The `GMSPlace` that was returned.
 */
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
    didAutocompleteWithPlace:(GMSPlace *)place
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/**
 * Called when a non-retryable error occurred when retrieving autocomplete predictions or place
 * details. A non-retryable error is defined as one that is unlikely to be fixed by immediately
 * retrying the operation.
 * <p>
 * Only the following values of `GMSPlacesErrorCode` are retryable:
 * <ul>
 * <li>kGMSPlacesNetworkError
 * <li>kGMSPlacesServerError
 * <li>kGMSPlacesInternalError
 * </ul>
 * All other error codes are non-retryable.
 * @param resultsController The `GMSAutocompleteResultsViewController` that generated the event.
 * @param error The `NSError` that was returned.
 */
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
    didFailAutocompleteWithError:(NSError *)error
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

@optional

/**
 * Called when the user selects an autocomplete prediction from the list but before requesting
 * place details. Returning NO from this method will suppress the place details fetch and
 * didAutocompleteWithPlace will not be called.
 * @param resultsController The `GMSAutocompleteResultsViewController` that generated the event.
 * @param prediction The `GMSAutocompletePrediction` that was selected.
 */
- (BOOL)resultsController:(GMSAutocompleteResultsViewController *)resultsController
      didSelectPrediction:(GMSAutocompletePrediction *)prediction
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/**
 * Called once every time new autocomplete predictions are received.
 * @param resultsController The `GMSAutocompleteResultsViewController` that generated the event.
 */
- (void)didUpdateAutocompletePredictionsForResultsController:
    (GMSAutocompleteResultsViewController *)resultsController
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/**
 * Called once immediately after a request for autocomplete predictions is made.
 * @param resultsController The `GMSAutocompleteResultsViewController` that generated the event.
 */
- (void)didRequestAutocompletePredictionsForResultsController:
    (GMSAutocompleteResultsViewController *)resultsController
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

@end

/**
 * `GMSAutocompleteResultsViewController` provides an interface that displays place autocomplete
 * predictions in a table view. The table view will be automatically updated as input text
 * changes.
 *
 * This class is intended to be used as the search results controller of a UISearchController. Pass
 * an instance of `GMSAutocompleteResultsViewController` to UISearchController's
 * initWithSearchResultsController method, then set the controller as the UISearchController's
 * searchResultsUpdater property.
 *
 * Use the `GMSAutocompleteResultsViewControllerDelegate` delegate protocol to be notified when a
 * place is selected from the list.
 */
__GMS_AVAILABLE_BUT_DEPRECATED_MSG(
    "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
    "(https://developers.google.com/maps/documentation/places/"
    "ios-sdk/google-places-swift) instead.")
@interface GMSAutocompleteResultsViewController : UIViewController <UISearchResultsUpdating>

/** Delegate to be notified when a place is selected. */
@property(nonatomic, weak, nullable) id<GMSAutocompleteResultsViewControllerDelegate> delegate
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** Filter to apply to autocomplete suggestions (can be nil). */
@property(nonatomic, strong, nullable) GMSAutocompleteFilter *autocompleteFilter
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The background color of table cells. */
@property(nonatomic, strong) IBInspectable UIColor *tableCellBackgroundColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The color of the separator line between table cells. */
@property(nonatomic, strong) IBInspectable UIColor *tableCellSeparatorColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The color of result name text in autocomplete results */
@property(nonatomic, strong) IBInspectable UIColor *primaryTextColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The color used to highlight matching text in autocomplete results */
@property(nonatomic, strong) IBInspectable UIColor *primaryTextHighlightColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The color of the second row of text in autocomplete results. */
@property(nonatomic, strong) IBInspectable UIColor *secondaryTextColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/** The tint color applied to controls in the Autocomplete view. */
@property(nonatomic, strong, nullable) IBInspectable UIColor *tintColor
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/**
 * Specify array of place property names to fetch for object `GMSPlace`. Defaults to returning all
 * details if not overridden.
 */
@property(nonatomic, strong) NSArray<GMSPlaceProperty> *placeProperties
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

/**
 * Specify individual place details to fetch for object `GMSPlace`. Defaults to returning all
 * details if not overridden.
 */
@property(nonatomic, assign) GMSPlaceField placeFields
    __GMS_AVAILABLE_BUT_DEPRECATED_MSG(
        "Use the <code>placeAutocomplete</code> View extension in Places Swift SDK "
        "(https://developers.google.com/maps/documentation/places/"
        "ios-sdk/google-places-swift) instead.")
        ;

@end

NS_ASSUME_NONNULL_END

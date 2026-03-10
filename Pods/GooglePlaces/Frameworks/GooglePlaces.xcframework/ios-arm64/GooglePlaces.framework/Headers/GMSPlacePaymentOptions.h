//
//  GMSPlacePaymentOptions.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
#import <Foundation/Foundation.h>


#import "GMSPlace.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Payment options at a place.
 */
@interface GMSPlacePaymentOptions : NSObject
/** Place Attribute for cash only. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute acceptsCashOnly;
/** Place Attribute for credit card. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute acceptsCreditCards;
/** Place Attribute for debit card. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute acceptsDebitCards;
/** Place Attribute for NFC mobile wallet. */
@property(nonatomic, readonly) GMSBooleanPlaceAttribute acceptsNFC;
@end

NS_ASSUME_NONNULL_END


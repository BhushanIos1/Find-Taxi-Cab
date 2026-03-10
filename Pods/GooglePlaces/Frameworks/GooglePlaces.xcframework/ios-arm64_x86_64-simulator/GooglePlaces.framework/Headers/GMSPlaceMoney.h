//
//  GMSPlaceMoney.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

/** Represents an amount of money with its currency type. */
@interface GMSPlaceMoney : NSObject

/** The three-letter currency code defined in ISO 4217. */
@property(nonatomic, readonly) NSString *currencyCode;

/**
 * The whole units of the amount. For example if "currencyCode" is "USD", then 1 unit is
 * one US dollar.
 */
@property(nonatomic, readonly) int64_t units;

/**
 * The number of nano (1e-9) units of the amount. The value must be between -999,999,999
 * and +999,999,999 inclusive. For example $-1.75 is represented as units=-1 and
 * nanos=-750,000,000.
 *
 * <p>If "units" is positive, "nanos" must be positive or zero. If "units" is zero, "nanos" can be
 * positive, zero, or negative. If "units" is negative, "nanos" must be negative or zero.
 */
@property(nonatomic, readonly) NSInteger nanos;

@end

NS_ASSUME_NONNULL_END


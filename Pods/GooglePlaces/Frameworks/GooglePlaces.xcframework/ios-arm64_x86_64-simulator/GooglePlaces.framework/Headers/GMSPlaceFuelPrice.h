//
//  GMSPlaceFuelPrice.h
//  Google Places SDK for iOS
//
//  Copyright 2025 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@class GMSPlaceMoney;

/** The type of fuel. */
typedef NS_ENUM(NSInteger, GMSPlaceFuelType) {
  GMSPlaceFuelTypeUnspecified = 0,
  GMSPlaceFuelTypeDiesel = 1,
  GMSPlaceFuelTypeRegularUnleaded = 2,
  GMSPlaceFuelTypeMidgrade = 3,
  GMSPlaceFuelTypePremium = 4,
  GMSPlaceFuelTypeSP91 = 5,
  GMSPlaceFuelTypeSP91E10 = 6,
  GMSPlaceFuelTypeSP92 = 7,
  GMSPlaceFuelTypeSP95 = 8,
  GMSPlaceFuelTypeSP95E10 = 9,
  GMSPlaceFuelTypeSP98 = 10,
  GMSPlaceFuelTypeSP99 = 11,
  GMSPlaceFuelTypeSP100 = 12,
  GMSPlaceFuelTypeLPG = 13,
  GMSPlaceFuelTypeE80 = 14,
  GMSPlaceFuelTypeE85 = 15,
  GMSPlaceFuelTypeMethane = 16,
  GMSPlaceFuelTypeBioDiesel = 17,
  GMSPlaceFuelTypeTruckDiesel = 18,
  GMSPlaceFuelTypeDieselPlus = 19,
  GMSPlaceFuelTypeE100 = 20,
};

/** Fuel price information for a given fuel type. */
@interface GMSPlaceFuelPrice : NSObject

/** The type of fuel. */
@property(nonatomic, readonly) GMSPlaceFuelType type;

/** The price of the fuel. */
@property(nonatomic, readonly) GMSPlaceMoney *price;

/** The time the fuel price was last updated. */
@property(nonatomic, readonly, nullable) NSDate *lastUpdateTime;

@end

NS_ASSUME_NONNULL_END


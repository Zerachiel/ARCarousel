//
//  FPCarouselNonXIBViewController.h
//  FoxPlay
//
//  Created by Huy Le on 4/29/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPCarouselNonXIBViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *carousel;

/**
 *  Carousel will automatically reload Data when property Data change
 */
@property (strong,nonatomic) NSArray *data;

/**
 *  Init carousel with array of Item model, and the property keyPath for URL of item's image in Model
 Ex:
 [carousel initWithArray:arrayModel keyPathForImageOfItem:@"imageUrl"];
 *
 *  @param array   Collection of item's model
 *  @param keyPath KeyPath for URL image of item's model
 */
- (void)initWithArray:(NSArray *)array keyPathForImageOfItem:(NSString *)keyPath;

/**
 *  Use this method to init Carousel
 *
 *  @param iFrame - Frame of carousel
 *
 *  @return id - self
 */
- (instancetype)initWithFrame:(CGRect)iFrame;

@end

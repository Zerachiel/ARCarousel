//
//  FPCarouselNonXIBViewController.m
//  FoxPlay
//
//  Created by Huy Le on 4/29/14.
//  Copyright (c) 2014 2359Media. All rights reserved.
//

#import "FPCarouselNonXIBViewController.h"



@interface FPCarouselNonXIBViewController ()

/**
 *  Configure Item for carousel
 *
 *  @param ITEM_WIDTH
 *  @param ITEM_HEIGHT
 *
 */
#define ITEM_WIDTH 360
#define ITEM_HEIGHT 240

// The size the Center item will increase
#define PERCENT_MAIN_ITEM 15

#define ITEM_SIZE CGSizeMake(ITEM_WIDTH,ITEM_HEIGHT)

/**
 *  Page Configure
 */
@property (assign,nonatomic) NSInteger count;
@property (assign,nonatomic) NSInteger centerItem;
@property (strong,nonatomic) NSArray *infData;
@property (assign,nonatomic) CGFloat pageWidth;

@property (assign,nonatomic) NSUInteger loopPointLeft;
@property (assign,nonatomic) NSUInteger loopPointRight;

@property (strong,nonatomic) UICollectionViewCell *previousCell;
@property (strong,nonatomic) UICollectionViewCell *nextCell;

@property (strong,nonatomic) UIPanGestureRecognizer *panGesture;

@property (assign,nonatomic) CGRect carouselFrame;

// Global Variable for Pan Gesture
@property (assign,nonatomic) CGPoint oldOffset;

// Carousel API

/**
 *  Don't call this API. It's called automatically by viewDidLoad
 */
- (void)setupCarousel;

@end

@implementation FPCarouselNonXIBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)iFrame {
    
    self = [super init];
    if (self) {
        
        
        self.carouselFrame = iFrame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:ITEM_SIZE];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumLineSpacing:10];
    
    // Config UICollectionView
    self.carousel = [[UICollectionView alloc] initWithFrame:self.carouselFrame collectionViewLayout:flowLayout];
    [self.carousel registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ReuseCell"];
    [self.carousel setDataSource:self];
    [self.carousel setDelegate:self];
    [self.view addSubview:self.carousel];
    
    //self.view.bounds = iFrame;
    [self.view setClipsToBounds:YES];
    [self.view setBackgroundColor:[UIColor blueColor]];
    
    [self setupCarousel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCarousel {
    
    // Sample data
    if (!self.data) {
        self.data = @[@0,@1,@2,@3,@4,@5];
    }
    
    // Method for infinity loop
    [self configInfinityLoop];
    
    // Config gesture
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(customPan:)];
    self.carousel.panGestureRecognizer.enabled = NO;
    [self.carousel addGestureRecognizer:self.panGesture];
    [self addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)configInfinityLoop {
    
    self.count = [self.data count];
    
    if(self.count < 3) {
        
        @throw [NSException exceptionWithName:@"Invalid Data for Carousel" reason:@"Data for carousel should more than 3 item!!!" userInfo:nil];
    }
    
    self.centerItem = 2;
    
    NSMutableArray *buildArray = [NSMutableArray arrayWithArray:self.data];
    [buildArray insertObject:self.data[self.count-2] atIndex:0];
    [buildArray insertObject:[self.data lastObject] atIndex:1];
    [buildArray addObject:self.data[0]];
    [buildArray addObject:self.data[1]];
    
    self.infData = [NSArray arrayWithArray:buildArray];
    
    self.count += 4;
    self.loopPointLeft = 1;
    self.loopPointRight = self.count - 2;
    
    // Scroll to Center Item
    [self.carousel scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"data"]) {
        
        [self configInfinityLoop];
        [self.carousel reloadData];
    }
}

#pragma mark - Action

- (IBAction)customPan:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        self.oldOffset = self.carousel.contentOffset;
        
    }
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [sender translationInView:self.carousel];
        CGPoint offset;
        offset.x = (self.oldOffset.x - translation.x);
        [self.carousel setContentOffset:offset animated:NO];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint translation = [sender translationInView:self.carousel];
        
        self.previousCell = [self.carousel cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0]];
        
        if (translation.x > 0) {
            
            if ((0 < self.centerItem) && (self.centerItem <= (self.count - 1))) {
                self.centerItem -= 1;
                
            }
        } else {
            
            if ((0 <= self.centerItem) && (self.centerItem < self.count - 1)) {
                self.centerItem += 1;
            }
        }
        
        [self scrollToCenterItem];
    }
    
}

- (void)scrollToCenterItem {
    
    CGPoint nextOffset;
    UICollectionViewCell *cell = [self.carousel cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0]];
    self.nextCell = cell;
    
    // Method for the next offset
    nextOffset.x = CGRectGetMinX(cell.frame) - (CGRectGetWidth(self.carousel.frame)/2 - (ITEM_WIDTH/2));
    
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        
        // Move to next offset
        [self.carousel setContentOffset:nextOffset];
        
        // Setup Emphrasing Center Item
        self.previousCell.frame = CGRectInset(self.previousCell.frame, PERCENT_MAIN_ITEM, PERCENT_MAIN_ITEM);
        self.previousCell.layer.zPosition = 0;
        self.previousCell.layer.cornerRadius = 0;
        
        self.nextCell.frame = CGRectInset(self.nextCell.frame, -PERCENT_MAIN_ITEM, -PERCENT_MAIN_ITEM);
        self.nextCell.layer.zPosition = 1000;
        self.nextCell.layer.cornerRadius = 10;
    } completion:^(BOOL finished) {
        
        // Infinity loop carousel
        if (self.centerItem == self.loopPointRight) {
            
            self.centerItem = 2;
            [self.carousel scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        
        if (self.centerItem == self.loopPointLeft) {
            
            self.centerItem = self.loopPointRight - 1;
            [self.carousel scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.centerItem inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.carousel dequeueReusableCellWithReuseIdentifier:@"ReuseCell" forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[UICollectionViewCell alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        [cell addSubview:imageView];
    }
    
    cell.layer.zPosition = 0;
    cell.layer.cornerRadius = 0;
    
    if (indexPath.row == self.centerItem) {
        
        cell.frame = CGRectInset(cell.frame, -PERCENT_MAIN_ITEM, -PERCENT_MAIN_ITEM);
        cell.layer.zPosition = 1000;
        cell.layer.cornerRadius = 10;
        self.previousCell = cell;
    }
    
    /**
     *  Implement code below to show the data of cell
     */
    NSUInteger number = [self.infData[indexPath.row] integerValue];
    switch (number) {
        case 0:
            [cell setBackgroundColor:[UIColor blueColor]];
            break;
            
        case 1:
            [cell setBackgroundColor:[UIColor greenColor]];
            break;
            
        case 2:
            [cell setBackgroundColor:[UIColor whiteColor]];
            break;
            
        case 3:
            [cell setBackgroundColor:[UIColor redColor]];
            break;
            
        case 4:
            [cell setBackgroundColor:[UIColor yellowColor]];
            break;
            
        case 5:
            [cell setBackgroundColor:[UIColor orangeColor]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

@end

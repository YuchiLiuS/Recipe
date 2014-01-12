//
//  RecipeViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/1/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipeViewController.h"
#import "BuyPlaceMapViewController.h"
#import "AddToShopListViewController.h"
#import "RecipeFetcher.h"

@interface RecipeViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *shopButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation RecipeViewController

#define BUTTONWIDTH 40
#define BUTTONHEIGHT 30
#define HOFFSET 20
#define VOFFSET 10

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateUI];
}

- (UIButton*)favButton
{
    if (!_favButton){
        _favButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return _favButton;
}

- (UIButton*)shopButton
{
    if (!_shopButton){
        _shopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return _shopButton;
}

- (UIButton*)mapButton
{
    if (!_mapButton) {
        _mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return _mapButton;
}

- (void)updateUI
{
    self.imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.width);
    self.scrollView.backgroundColor = [UIColor colorWithRed:250/255.0 green:184/255.0 blue:117/255.0 alpha:1];
    [self setUpButton];
    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.scrollView.frame.size.width, FLT_MAX)];
    CGRect rect = CGRectMake(0,self.imageView.frame.size.height+self.favButton.frame.size.height+VOFFSET,self.scrollView.frame.size.width,size.height);
    self.textView.frame = rect;
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,self.imageView.frame.size.height+self.textView.frame.size.height+self.favButton.frame.size.height+VOFFSET);
    [self.scrollView addSubview:self.imageView];
    [self.scrollView addSubview:self.favButton];
    [self.scrollView addSubview:self.shopButton];
    [self.scrollView addSubview:self.mapButton];
    [self.scrollView addSubview:self.textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)setUpButton
{
    NSString *title = [self.recipe.isfavorite isEqualToNumber:[NSNumber numberWithBool:NO]]? @"♡":@"♥";
    [self.favButton setTitle:title forState:UIControlStateNormal];
    [self.favButton addTarget:self
                    action:@selector(addToFavorite:)
          forControlEvents:UIControlEventTouchDown];
    self.favButton.frame = CGRectMake(self.scrollView.frame.size.width-HOFFSET-BUTTONWIDTH,self.imageView.frame.size.height+VOFFSET,BUTTONWIDTH,BUTTONHEIGHT);
    self.favButton.backgroundColor = [UIColor whiteColor];
    [[self.favButton layer] setCornerRadius:8.0f];
    [[self.favButton layer] setMasksToBounds:YES];
    [[self.favButton layer] setBorderWidth:1.0f];
    
    UIImage *mapImage = [UIImage imageNamed:@"maps"];
    [self.mapButton setBackgroundImage:mapImage forState:UIControlStateNormal];
    [self.mapButton addTarget:self
                       action:@selector(goToMap:)
             forControlEvents:UIControlEventTouchDown];
    self.mapButton.frame = CGRectMake(HOFFSET,self.imageView.frame.size.height+VOFFSET,mapImage.size.width,BUTTONHEIGHT);
    
    UIImage *shopImage = [UIImage imageNamed:@"shoppingcart"];
    [self.shopButton setBackgroundImage:shopImage forState:UIControlStateNormal];
    [self.shopButton addTarget:self
                        action:@selector(addToShopList:)
              forControlEvents:UIControlEventTouchDown];
    self.shopButton.frame = CGRectMake(2*HOFFSET+mapImage.size.width,self.imageView.frame.size.height+VOFFSET,shopImage.size.width,BUTTONHEIGHT);
    
}

- (void)addToShopList:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"Add Shop List" sender:sender];
}

- (void)addToFavorite:(UIButton *)sender
{
    BOOL isfavorited = [self.recipe.isfavorite isEqualToNumber:[NSNumber numberWithBool:YES]];
    if (isfavorited) {
        self.recipe.isfavorite = [NSNumber numberWithBool:NO];
        [self.favButton setTitle:@"♡" forState:UIControlStateNormal];
    }
    else{
        self.recipe.isfavorite = [NSNumber numberWithBool:YES];
        [self.favButton setTitle:@"♥" forState:UIControlStateNormal];
    }
}

#pragma mark - Navigation

- (void)goToMap:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"Show Map" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Show Map"])
    {
        if ([segue.destinationViewController isKindOfClass:[BuyPlaceMapViewController class]]) {
            BuyPlaceMapViewController *bmvc = (BuyPlaceMapViewController *)segue.destinationViewController;
            bmvc.buyPlace = self.recipe.buyPlace;
            
        }
    }else if ([[segue identifier] isEqualToString:@"Add Shop List"])
    {
        if ([segue.destinationViewController isKindOfClass:[AddToShopListViewController class]]) {
            AddToShopListViewController *asvc = (AddToShopListViewController *)segue.destinationViewController;
            asvc.ingredients = [NSKeyedUnarchiver unarchiveObjectWithData:self.recipe.ingredients];
            asvc.buyPlace = self.recipe.buyPlace;
            asvc.managedObjectContext = self.recipe.managedObjectContext;
        }
    }
}

#pragma mark - Properties

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (UITextView *)textView
{
    if (!_textView) _textView = [[UITextView alloc] init];
    return _textView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.delegate = self;
}

#pragma mark - UIScrollViewDelegate

// mandatory zooming method in UIScrollViewDelegate protocol

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}


- (void)setRecipe:(Recipe *)recipe
{
    _recipe = recipe;
    [self startDownloadingImage];
    [self setText];
}

- (void)setText
{
    if (self.recipe) {
        NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] init];
        
        NSArray *ingredientarray = [NSKeyedUnarchiver unarchiveObjectWithData:self.recipe.ingredients];
        NSArray *procedurearray = [NSKeyedUnarchiver unarchiveObjectWithData:self.recipe.procedures];
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0];
        NSMutableAttributedString *ingtitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Ingredients\r\r"]];
        [ingtitle setAttributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]} range:NSMakeRange(0, [ingtitle length])];
        [contentText appendAttributedString:ingtitle];
        for (NSDictionary *ingredient in ingredientarray){
            NSMutableAttributedString *ingtext = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@\r", [ingredient objectForKey:RECIPE_INGREDIENT_QUANTITY],[ingredient objectForKey:RECIPE_INGREDIENT_ITEM]]];
            [ingtext setAttributes:@{NSFontAttributeName:font}
                             range:NSMakeRange(0, [ingtext length])];
            [contentText appendAttributedString:ingtext];
        }
        
        NSMutableAttributedString *proctitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\rProcedures\r\r"]];
        [proctitle setAttributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]} range:NSMakeRange(0, [proctitle length])];
        [contentText appendAttributedString:proctitle];
        
        for (NSString *procedure in procedurearray){
            NSInteger procIndex = [procedurearray indexOfObject:procedure];
            NSMutableAttributedString *proctext = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d:  %@\r\r",(int)procIndex+1, procedure]];
            [proctext setAttributes:@{NSFontAttributeName:font}
                              range:NSMakeRange(0, [proctext length])];
            [contentText appendAttributedString:proctext];
        }
        
        self.textView.attributedText = contentText;
        
    }
    
}

//same as in lecture demo code.
- (void)startDownloadingImage
{
    self.image = nil;
    
    if (self.recipe.imageURL)
    {
        [self.spinner startAnimating];
        NSURL *imageURL = [NSURL URLWithString:self.recipe.imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        
        // another configuration option is backgroundSessionConfiguration (multitasking API required though)
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // create the session without specifying a queue to run completion handler on (thus, not main queue)
        // we also don't specify a delegate (since completion handler is all we need)
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                            // this handler is not executing on the main queue, so we can't do UI directly here
                                                            if (!error) {
                                                                if ([request.URL isEqual:[NSURL URLWithString:self.recipe.imageURL]]) {
                                                                    // UIImage is an exception to the "can't do UI here"
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                }
                                                            }
                                                        }];
        [task resume]; // don't forget that all NSURLSession tasks start out suspended!
    }
}

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}
@end

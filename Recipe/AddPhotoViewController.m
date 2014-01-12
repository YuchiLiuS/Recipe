//
//  AddPhotoViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/5/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddPhotoViewController () <UITextViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation AddPhotoViewController

#pragma mark - Capabilities

+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Alerts
//Same as in lecture demo code.
- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Add Photo"
                                message:msg
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"DishShare";
    self.textView.delegate = self;
	self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[self class] canAddPhoto]) {
        [self fatalAlert:@"Sorry, this device cannot add a photo."];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Target/Action

- (IBAction)TakePhoto:(id)sender {
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
}

- (IBAction)UsePhotoLibrary:(id)sender {
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)PostMessage:(id)sender {
    NSArray *activityitems;
    if (self.image != nil) {
        activityitems = @[self.textView.text, self.image];
    } else {
        activityitems = @[self.textView.text];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityitems applicationActivities:nil];
    [self presentViewController:activityController
                       animated:YES
                     completion:nil];
}

- (IBAction)cancel:(id)sender {
    self.textView.text = @"#From Recipe App#";
    self.image = nil;
    [self.textView resignFirstResponder];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

//Hide the keyboard when touched anywhere not in the textView.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.textView isFirstResponder] && [touch view] != self.textView) {
        [self.textView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

@end

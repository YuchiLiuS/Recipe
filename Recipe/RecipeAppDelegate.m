//
//  RecipeAppDelegate.m
//  Recipe
//
//  Created by yuchiliu on 11/29/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "RecipeAppDelegate.h"
#import "RecipeFetcher.h"
#import "Recipe+Create.h"
#import "RecipeDataBaseAvailability.h"


@interface RecipeAppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^recipeDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *recipeDownloadSession;
@property (strong, nonatomic) NSTimer *recipeForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *recipeDatabaseContext;

@end

@implementation RecipeAppDelegate

#define RECIPE_FETCH @"Recipe Just Uploaded Fetch"

// how often (in seconds) we fetch new recipes if we are in the foreground
#define FOREGROUND_RECIPE_FETCH_INTERVAL (60*60)

// how long we'll wait for a recipe fetch to return when we're in the background
#define BACKGROUND_RECIPE_FETCH_TIMEOUT (10)


#pragma mark - UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // when we're in the background, fetch as often as possible (which won't be much)
    // forgot to include this line in the demo during lecture, but don't forget to include it in your app!
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    // we get our managed object context by creating it ourself in a category on PhotomaniaAppDelegate
    // but in your homework assignment, you must get your context from a UIManagedDocument
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([fileManager fileExistsAtPath:[url path]]){
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady:document];
            }
            else {
                NSLog(@"couldn't open document at %@", url);
            }
        }];
    }else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success){
              if (success) {
                  [self documentIsReady:document];
              }
              if (!success) {
                  NSLog(@"couldn't create document at %@",url);
              }
          }];
    }
    return YES;
}

//If app is active, the alert message needs to be delivered programmatically.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([application applicationState]== UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)documentIsReady:(UIManagedDocument*)document
{
    if (document.documentState == UIDocumentStateNormal) {
        self.recipeDatabaseContext = document.managedObjectContext;
        [self startRecipeFetch];
    }
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.recipeDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_RECIPE_FETCH_TIMEOUT; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[RecipeFetcher URLforRecipes]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Recipe background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultNoData);
                                                            } else {
                                                                [self loadrecipePhotosFromLocalURL:localFile
                                                                                       intoContext:self.recipeDatabaseContext
                                                                               andThenExecuteBlock:^{
                                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                                               }
                                                                 ];
                                                            }
                                                        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.recipeDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - Database Context

- (void)setRecipeDatabaseContext:(NSManagedObjectContext *)recipeDatabaseContext
{
    _recipeDatabaseContext = recipeDatabaseContext;
    
    [self.recipeForegroundFetchTimer invalidate];
    self.recipeForegroundFetchTimer = nil;
    
    if (self.recipeDatabaseContext)
    {
        self.recipeForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_RECIPE_FETCH_INTERVAL
                                                                           target:self
                                                                         selector:@selector(startRecipeFetch:)
                                                                         userInfo:nil
                                                                          repeats:YES];
    }
    NSDictionary *userInfo = self.recipeDatabaseContext ? @{ RecipeDatabaseAvailabilityContext : self.recipeDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:RecipeDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - recipe Fetching

- (void)startRecipeFetch
{
    [self.recipeDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.recipeDownloadSession downloadTaskWithURL:[RecipeFetcher URLforRecipes]];
            task.taskDescription = RECIPE_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

- (void)startRecipeFetch:(NSTimer *)timer
{
    [self startRecipeFetch];
}


- (NSURLSession *)recipeDownloadSession // the NSURLSession we will use to fetch recipe data in the background
{
    if (!_recipeDownloadSession) {
        static dispatch_once_t onceToken; // dispatch_once ensures that the block will only ever get executed once per application launch
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:RECIPE_FETCH];
            _recipeDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
        });
    }
    return _recipeDownloadSession;
}

- (NSArray *)recipesAtURL:(NSURL *)url
{
    NSDictionary *recipePropertyList;
    NSData *recipeJSONData = [NSData dataWithContentsOfURL:url];  // will block if url is not local!
    if (recipeJSONData) {
        recipePropertyList = [NSJSONSerialization JSONObjectWithData:recipeJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [recipePropertyList valueForKeyPath:RESULTS_RECIPES];
}

- (void)loadrecipePhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *recipes = [self recipesAtURL:localFile];
        [context performBlock:^{
            [Recipe loadRecipesFromArray:recipes intoManagedObjectContext:context];
            [context save:NULL];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    if ([downloadTask.taskDescription isEqualToString:RECIPE_FETCH]) {
        [self loadrecipePhotosFromLocalURL:localFile
                               intoContext:self.recipeDatabaseContext
                       andThenExecuteBlock:^{
                           [self recipeDownloadTasksMightBeComplete];
                       }
         ];
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.recipeDownloadSession)) {
        NSLog(@"recipe background download session failed: %@", error.localizedDescription);
        [self recipeDownloadTasksMightBeComplete];
    }
}

- (void)recipeDownloadTasksMightBeComplete
{
    if (self.recipeDownloadBackgroundURLSessionCompletionHandler) {
        [self.recipeDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.recipeDownloadBackgroundURLSessionCompletionHandler;
                self.recipeDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } 
        }];
    }
}

@end

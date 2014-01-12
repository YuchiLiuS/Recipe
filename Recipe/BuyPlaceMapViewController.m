//
//  BuyPlaceMapViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/4/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "BuyPlaceMapViewController.h"
#import "CustomAnnotation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BuyPlaceMapViewController () <MKMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation BuyPlaceMapViewController

#define MAPREGIONSIZE 30000

- (void)setBuyPlace:(NSString *)buyPlace
{
    _buyPlace = buyPlace;
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:msg
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

#pragma mark - Location

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

+(BOOL)canfindLocation
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
        return YES;
    }
    return NO;
}

- (void)searchBuyPlace
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.buyPlace;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, MAPREGIONSIZE, MAPREGIONSIZE);
    request.region = region;
    MKLocalSearch  *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count==0) {
            NSLog(@"No matches");
        }
        else
            for (MKMapItem *item in response.mapItems)
            {
                CustomAnnotation *annotation = [[CustomAnnotation alloc] init];
                annotation.mapItem = item;
                annotation.coordinate = item.placemark.coordinate;
                annotation.title = item.name;
                [self.mapView addAnnotation:annotation];
            }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.location = newLocation;
    [self.locationManager stopUpdatingLocation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, MAPREGIONSIZE, MAPREGIONSIZE);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    [self searchBuyPlace];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self fatalAlert:@"No location detect service available"];
}

#pragma mark - MapView


- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == self.mapView.userLocation ){
        return nil; //Do not change current location to pin.
    }
    
    static NSString *reuseId = @"BuyPlaceAnnotationView";
    MKPinAnnotationView *view = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        view.pinColor = MKPinAnnotationColorRed;
        UIButton *routeButton = [[UIButton alloc] init];
        [routeButton setBackgroundImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
        [routeButton sizeToFit];
        view.leftCalloutAccessoryView = routeButton;
        UIButton *appleMapButton = [[UIButton alloc] init];
        [appleMapButton setBackgroundImage:[UIImage imageNamed:@"applemaps"] forState:UIControlStateNormal];
        [appleMapButton sizeToFit];
        view.rightCalloutAccessoryView = appleMapButton;
        view.animatesDrop = YES;
        
    }
    
    view.annotation = annotation;
    
    return view;
}

//Provide two ways to use the Map, by touching left button you can show the route in the map. Or by touching
//right button you can show it in the apple map.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSArray *routearray = [self.mapView overlays];
    [self.mapView removeOverlays:routearray];//clear former route search;
    if ([view.annotation isKindOfClass: [CustomAnnotation class]]){
        CustomAnnotation *annotation = (CustomAnnotation *)view.annotation;
        if (control == view.leftCalloutAccessoryView){
            [self searchRouteforMapItem:annotation.mapItem];
        }
        else if (control == view.rightCalloutAccessoryView){
            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving};
            [annotation.mapItem openInMapsWithLaunchOptions:options];
        }
    }
}

- (void)searchRouteforMapItem:(MKMapItem*)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [self showRoute:response];
    }];
}

- (void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayPathRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *mkprenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    mkprenderer.strokeColor = [UIColor colorWithRed:102.0/255.0 green:186.0/255.0 blue:255.0/255.0 alpha:1.0];
    mkprenderer.lineWidth = 4;
    return mkprenderer;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
    self.title = @"Map";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[self class] canfindLocation]) {
        [self fatalAlert:@"Don't have access to use location service."];
    } else { // should check that location services are enabled first
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

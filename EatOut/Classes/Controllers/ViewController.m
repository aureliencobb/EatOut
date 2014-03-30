//
//  ViewController.m
//  EatOut
//
//  Created by Aurelien Cobb on 14/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import "ViewController.h"
#import "GooglePlaceRequest.h"
#import "EatOutCell.h"
#import "Place.h"
#import "Persistence.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

const CGFloat kDefaultAnimationDuration = 0.3;
const CGFloat kMetersInAMile = 1609.344;

static NSString * const kAnnotationViewIdentifier = @"AnnotationViewIdentifier";
NSString * const kRestaurantType = @"restaurant";

NS_ENUM(NSInteger, DisplayType) {
    DisplayTypeList = 0,
    DisplayTypeMap
};

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, GooglePlaceRequestDelegate>

// Views
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControllerChoseDisplay;
@property (strong, nonatomic) UIRefreshControl * refreshControl;
@property (strong, nonatomic) UIBarButtonItem * refreshBarButton;

// Location
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D mapCentre;

// Data
@property (copy, nonatomic) NSArray * googleData;
@property (strong, nonatomic) GooglePlaceRequest * googleRequest;

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCloses) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appCloses) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActivates) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.tableView addSubview:self.refreshControl];
    [self setupLocationManager];
    [self setupData];
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    [super viewDidUnload];
}

- (void)setupLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

#pragma mark - Getter / Setter


- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (void)setGoogleData:(NSArray *)googleData {
    _googleData = [googleData copy];
    if (_googleData.count) {
        [self.tableView reloadData];
    }
    [self replaceOldAnnotationsWith:_googleData];
}

#pragma mark - Target Action

- (IBAction)segmentDisplaySelect:(UISegmentedControl *)sender {
    [self switchDisplayTypeTo:sender.selectedSegmentIndex];
}

- (IBAction)refresh:(id)sender {
    [self refreshData];
}

#pragma mark - Google API

- (void)fetchGoogleDataFromType:(NSString *)type radius:(CGFloat)radius {
    self.googleRequest = [GooglePlaceRequest requestWithType:type radius:radius latitude:self.mapCentre.latitude longitude:self.mapCentre.longitude delegate:self];
}

#pragma mark - NSNotification

- (void)appCloses {
    self.mapView.showsUserLocation = NO;
    [[Persistence persistence] savePlaces:self.googleData];
}

- (void)appActivates {
    self.mapView.showsUserLocation  = YES;
}

#pragma mark - Private Methods

- (void)setupData {
    NSArray * places = [[Persistence persistence] retrieveSavedPlaces];
    if (places.count) {
        self.googleData = places;
    }
}

- (void)switchDisplayTypeTo:(NSInteger)displayType {
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.mapView.alpha = displayType == DisplayTypeMap;
    }];
}

- (void)refreshData {
    [self.googleRequest cancel];
    self.refreshBarButton = self.navigationItem.rightBarButtonItem;
    [self fetchGoogleDataFromType:kRestaurantType radius:kMetersInAMile];
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)endrefreshing {
    [self.googleRequest cancel];
    [self.refreshControl endRefreshing];
    self.navigationItem.rightBarButtonItem = self.refreshBarButton;
}

- (void)replaceOldAnnotationsWith:(NSArray *)annotations {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[Place class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    for (id<MKAnnotation> newAnnotation in annotations) {
        [self.mapView addAnnotation:newAnnotation];
    }
}

#pragma mark - GooglePlaceRequestDelegate methods

- (void)googlePlaceRequest:(GooglePlaceRequest *)request didFailWithError:(NSError *)error {
    [self endrefreshing];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] show];
}

- (void)googlePlaceRequest:(GooglePlaceRequest *)request didSucceedWithPlaces:(NSArray *)places {
    [self endrefreshing];
    self.googleData = places;
    [[Persistence persistence] savePlaces:self.googleData];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.googleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EatOutCell * cell = [tableView dequeueReusableCellWithIdentifier:[EatOutCell reuseIdentifier]];
    if (!cell) {
        cell = [EatOutCell cell];
    }
    Place * place = [self.googleData objectAtIndex:indexPath.row];
    if (!place.icon) {
        dispatch_queue_t imageLoadingQueue = dispatch_queue_create("imageLoadingQueue", NULL);
        dispatch_async(imageLoadingQueue, ^{
            place.icon = [NSData dataWithContentsOfURL:[NSURL URLWithString:place.iconUrlStr]];
            UIImage * image = [UIImage imageWithData:place.icon];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell updateImage:image];
            });
        });
    }
    if ([place isKindOfClass:[Place class]]) {
        cell.place = place;
    }
    return cell;
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView * annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationViewIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationViewIdentifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
    }
    annotationView.annotation = annotation;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapCentre = self.mapView.centerCoordinate;
}

#pragma mark - CLLocationManagerDelegate methods {

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, kMetersInAMile, kMetersInAMile);
        [self.mapView setRegion:region animated:YES];
        self.mapCentre = _locationManager.location.coordinate;
        [self refreshData];
    });
}

@end

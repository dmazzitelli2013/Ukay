//
//  MapViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 5/27/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)dealloc
{
    [_mapView release];
    
    if(_latitude) {
        [_latitude release];
    }
    
    if(_longitude) {
        [_longitude release];
    }
    
    if(_annotationTitle) {
        [_annotationTitle release];
    }
    
    if(_annotationSubtitle) {
        [_annotationSubtitle release];
    }

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView setMapType:MKMapTypeStandard];
    
    if(!self.latitude || !self.longitude) {
        return;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = [self.latitude doubleValue];
    coord.longitude = [self.longitude doubleValue];
    
    MKCoordinateSpan span = {.latitudeDelta = 0.02, .longitudeDelta = 0.02};
    MKCoordinateRegion region = {coord, span};
    
    [self.mapView setRegion:region animated:YES];
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = coord;
    
    if(self.annotationTitle) {
        annotationPoint.title = self.annotationTitle;
    }
    
    if(self.annotationSubtitle) {
        annotationPoint.subtitle = self.annotationSubtitle;
    }

    [self.mapView addAnnotation:annotationPoint];
    [annotationPoint release];
}

#pragma mark - IBAction methods

- (IBAction)closeMapButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

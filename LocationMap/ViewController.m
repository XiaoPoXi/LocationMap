//
//  ViewController.m
//  LocationMap
//
//  Created by baikal on 15/11/23.
//  Copyright (c) 2015年 baikal. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MPAnontation.h"

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate>
{
    MKMapView *_mapView;
}
//当前位置和定位管理器
@property (nonatomic,strong)CLLocation *currentLocation;
@property (nonatomic,strong)CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatMapView];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager.delegate = self;
    //设置定位的距离
    self.locationManager.distanceFilter = 100;
    //设置定位精确度
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //最精确，10米，百米经度，千米的经度，三千米
//    extern const CLLocationAccuracy kCLLocationAccuracyBest;
//    extern const CLLocationAccuracy kCLLocationAccuracyNearestTenMeters;
//    extern const CLLocationAccuracy kCLLocationAccuracyHundredMeters;
//    extern const CLLocationAccuracy kCLLocationAccuracyKilometer;
//    extern const CLLocationAccuracy kCLLocationAccuracyThreeKilometers;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.searchTextField.delegate = self;
}

- (void)creatMapView{
    _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    //地图类型
    _mapView.mapType = MKMapTypeStandard;
//    MKMapTypeStandard = 0,默认
//    MKMapTypeSatellite,   卫星
//    MKMapTypeHybrid       混合
    _mapView.scrollEnabled = YES;
    
    //经纬度的结构体
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(40.112481, 116.245360);
    _mapView.centerCoordinate = coordinate;
    //确定一个范围，以某经纬度为中心，经度（南北）距离和纬度（东西）距离构成一个长方体活着正方形
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 30000, 30000);
    _mapView.region =region;
    _mapView.delegate = self;
    //默认天机mapview是self.view的子视图，把mapview放到self.view上，再search下方
    [self.view insertSubview:_mapView belowSubview:self.searchTextField];
    
    //自定义大头针
    MPAnontation *anno = [[MPAnontation alloc]init];
    anno.title = @"北京科技";
    anno.subtitle = @"欢迎光临";
    anno.coordinate = coordinate;
    [_mapView addAnnotation:anno];
    
}

#pragma mark CLLocationManagerDelegate
//如果定位成功调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation = [locations lastObject];
    NSLog(@"%.6f------%.6f",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude);
}

#pragma mark MKMapViewDelegate
//反选大头针时候调用这个方法
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
}
//选中大头针时候调用这个方法
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
}

//加载大头针或者刷新大头针时候调用
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //复用机制，当移除屏幕的时候加入队列，当出现在屏幕时先从队列中取出
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"map"];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"map"];
        pinView.canShowCallout = YES;
    }
    //赋值大头针
    pinView.annotation = annotation;
    //定义大头针的图片
    pinView.image = [UIImage imageNamed:@"location"];
    //定义大头针的视图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    imageView.image = [UIImage imageNamed:@"icon"];
    [pinView addSubview:imageView];
    return pinView;
}

#pragma mark UITextFieldDelegate

//结束编辑
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//点击搜索的时候调用
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    //初始化搜索请求
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    //请求属性
    request.naturalLanguageQuery = textField.text;
    //搜索的范围
    //以经纬度原点为中心，经度距离和纬度距离的经纬度值
    MKCoordinateRegion region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.03, 0.03));
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        //移除map上所有大头针
        [_mapView removeAnnotations:_mapView.annotations];
        for (MKMapItem *item in response.mapItems) {
            MPAnontation *anno = [[MPAnontation alloc]init];
            anno.title = item.name;
            anno.subtitle = item.phoneNumber;
            anno.coordinate = item.placemark.coordinate;
            [_mapView addAnnotation:anno];
        }
    }];
    return YES;
}


//延时加载，（懒加载）是我们项目和面试经常遇到的一个对app优化的重要方法，类似重写set方法
- (CLLocationManager *)locationManager{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc]init];
    }
    return _locationManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

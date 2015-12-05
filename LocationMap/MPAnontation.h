//
//  MPAnontation.h
//  LocationMap
//
//  Created by baikal on 15/11/23.
//  Copyright (c) 2015年 baikal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MPAnontation : NSObject<MKAnnotation>
//这个是我们自定义大头针类
//定制三个属性
//一个结构体，经纬度的结构体
@property (nonatomic,assign)CLLocationCoordinate2D coordinate;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *subtitle;

@end

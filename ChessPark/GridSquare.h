//
//  GridSquare.h
//  ChessPark
//
//  Created by Adam Fraser on 9/30/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface GridSquare : UIControl

@property (strong, nonatomic) NSString *stringValue;
@property (strong, nonatomic) NSString *colour;

@property (strong, nonatomic) UIView *displaySquare;
@property (strong, nonatomic) UILabel *displayLabel;

@property int row;
@property int column;
@property int size;

- (void)refresh;




@end

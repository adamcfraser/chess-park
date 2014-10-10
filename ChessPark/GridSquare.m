//
//  GridSquare.m
//  ChessPark
//
//  Created by Adam Fraser on 9/30/14.
//  Copyright (c) 2014 Adam Fraser. All rights reserved.
//

#import "GridSquare.h"


@implementation GridSquare
{
    NSArray *colNames;
    NSArray *whitePieces;
    NSArray *blackPieces;
    NSString *pieceColour;
}

- (void)initSquare {
    colNames = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H",nil];
    whitePieces = [NSArray arrayWithObjects:@"R",@"N",@"B",@"K",@"Q",@"P",nil];
    blackPieces = [NSArray arrayWithObjects:@"r",@"n",@"b",@"k",@"q",@"p",nil];
    _stringValue = @"";
    _size = 38;
    _colour=@"black";
    self.autoresizingMask = UIViewAutoresizingNone;
    
    _displaySquare = [[UIView alloc] initWithFrame:CGRectMake(0,0,_size, _size)];
    [self addSubview:_displaySquare];
    _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, _size, _size)];
    _displayLabel.text = _stringValue;
    
    
    [_displaySquare addSubview:_displayLabel];
    
    
}

- (void)refresh {
    
    if ([@"black" isEqual: _colour]) {
        //_displaySquare.backgroundColor = RGB(51,51,51);
        _displaySquare.backgroundColor = RGB(170, 170, 170);
    } else {
        _displaySquare.backgroundColor = RGB(221, 221, 221);
    }
    
    if ([whitePieces containsObject: _stringValue]) {
        pieceColour = @"W";
        [_displayLabel setTextColor:[UIColor whiteColor]];
        //[_displayLabel setShadowColor:[UIColor lightGrayColor]];
    } else {
        pieceColour = @"B";
        [_displayLabel setTextColor:[UIColor blackColor]];
        //[_displayLabel setShadowColor:[UIColor lightGrayColor]];
    }
    
    _displayLabel.text = [_stringValue uppercaseString];
    [_displayLabel setFont:[UIFont boldSystemFontOfSize: 20]];
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    //[_displayLabel setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    if (_column == 0) {
        UILabel *rowLabel = [[UILabel alloc] initWithFrame:CGRectMake(-_size/4, _size/2, _size/4, _size/4)];
        rowLabel.text = [NSString stringWithFormat:@"%d", 8 -_row];
        [rowLabel setFont:[UIFont systemFontOfSize:6]];
        [_displaySquare addSubview:rowLabel];
    }
    if (_row == 0) {
        UILabel *colLabel = [[UILabel alloc] initWithFrame:CGRectMake(_size/2, -_size/3, _size/4, _size/4)];
        colLabel.text = colNames[_column];
        [colLabel setFont:[UIFont systemFontOfSize:6]];
        [_displaySquare addSubview: colLabel];
    }
    [self setNeedsDisplay];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSquare];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initSquare];
    }
    return self;
}





@end

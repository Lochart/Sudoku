//
//  KnucleViewViewController.m
//  Sudoku
//
//  Created by Nikolay on 23.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "KnucleView.h"

@interface KnucleView ()

@property (nonatomic, getter=isEditable) BOOL editable;

@end

@implementation KnucleView

+ (instancetype)knuckeWithNumber:(NSUInteger)number
{
    KnucleView *selector = [self new];
    [selector setNumber:number];
    [selector setEditable:number == 0];
    
    return selector;
}

-(void)setNumber:(NSUInteger)number{
    _number = number;
    
    NSString *imageName = [NSString stringWithFormat:@"menu_Number_%lu", (unsigned long)number];
    UIImage *numberImage = [UIImage imageNamed:imageName];
    
    [self setImage:numberImage];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    KnucleView *copy = [KnucleView knuckeWithNumber:self.number];
    [copy setFrame:self.frame];
    
    return copy;
}

@end

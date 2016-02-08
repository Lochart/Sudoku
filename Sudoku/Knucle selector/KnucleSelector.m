//
//  KnucleSelector.m
//  Sudoku
//
//  Created by Alexander Kozin on 19.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "KnucleSelector.h"

@interface KnucleSelector ()

@property (weak, nonatomic) KnucleSelector *movableCopy;

@end

@implementation KnucleSelector

+ (instancetype)knuckeWithNumber:(NSUInteger)number
{
    KnucleSelector *selector = [super knuckeWithNumber: number];
    [selector setUserInteractionEnabled:YES];
    
    return selector;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    KnucleSelector *movableCopy = [self copy];
    
    UIView *targetView = self.targetView;
    
    [targetView addSubview:movableCopy];
    
    [self setMovableCopy:movableCopy];
    
    [self moveCopyForTouches:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self moveCopyForTouches:touches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    KnucleSelector *movableCopy = self.movableCopy;
    
    NSDictionary *userInfo = @{@"kKnucleKey": movableCopy};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDropKnucle"
                                                    object:movableCopy
                                                      userInfo:userInfo];
    
    [movableCopy removeFromSuperview];
}

- (void)moveCopyForTouches:(NSSet<UITouch *> *)touches
{
    UITouch *touch = [touches anyObject];
    [self.movableCopy setCenter:[touch locationInView:self.targetView]];
}

@end

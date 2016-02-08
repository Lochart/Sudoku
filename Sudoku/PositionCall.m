//
//  PositionCall.m
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "PositionCall.h"
@import UIKit;

static NSComparator comparator = ^NSComparisonResult(PositionCall *pos1, PositionCall *pos2) {
    if (pos1.possibleValues.count < pos2.possibleValues.count)
        return NSOrderedAscending;
    else if (pos1.possibleValues.count == pos2.possibleValues.count) {
        return NSOrderedSame;
    } else
        return NSOrderedDescending;
};

@implementation PositionCall

+ (NSComparator)comparator {
    return comparator;
}

-(instancetype) initWithY: (NSUInteger) y{
    self = [ self init];
    if (self) {
        self.y = y;
    }
    return self;
}

-(instancetype) initWithX: (NSUInteger) x Y: (NSUInteger) y{
    
    self = [ self init];
    if (self) {
        self.value = @(0);
        self.x = x;
        self.y = y;
        self.possibleValues = [self shuffleNumbers:[[NSMutableArray alloc] initWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9)]]];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    
    PositionCall *newPos = [PositionCall new];
    
    newPos.value = self.value;
    newPos.x = self.x;
    newPos.y = self.y;
    newPos.possibleValues = [[NSMutableArray alloc] initWithArray:self.possibleValues.mutableCopy];
    
    return  newPos;
}

-(NSMutableArray*) shuffleNumbers: (NSMutableArray*) arr{
    
    NSUInteger i = arr.count;
    while (i > 1) {
        uint32_t randInd1 = arc4random_uniform((uint32_t)arr.count);
        uint32_t randInd2 = arc4random_uniform((uint32_t)arr.count);
        
        if (randInd1 != randInd2) {
            id val = arr[randInd1];
            arr[randInd1] = arr[randInd2];
            arr[randInd2] = val;
            i--;
        }
        
    }
    return arr;
}

- (void) remove: (id) value {
    [self.possibleValues removeObject:value];
}

- (void) add: (id) value {
    if (![self.possibleValues containsObject:value])
        [self.possibleValues addObject:value];
}

- (NSString *)printableValue {
    return self.value.integerValue == 0 ? @"-" : [self.value stringValue];
}

@end

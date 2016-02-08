//
//  PositionCall.h
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PositionCall : NSObject<NSCopying>

+ (NSComparator) comparator;

-(instancetype) initWithY: (NSUInteger) y;

-(instancetype) initWithX: (NSUInteger) x Y: (NSUInteger) y;

-(NSMutableArray*) shuffleNumbers: (NSMutableArray*) arr;

@property NSUInteger x, y;

@property NSMutableArray* possibleValues;

@property NSNumber* value;

@property bool temporary;

@property (readonly) NSString* printableValue;

- (void) remove: (id) value;
- (void) add: (id) value;


@end

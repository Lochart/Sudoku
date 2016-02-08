//
//  Solution.h
//  Sudoku
//
//  Created by Nikolay on 06.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PositionCall;

typedef NS_ENUM(NSInteger, SolutionState){
    Invalid,
    Progress,
    Solved
};

@interface Solution : NSObject<NSCopying>

-(instancetype) initSolution;
-(instancetype) initSolutionWithArray: (NSArray*) arrayOfvalues;

-(BOOL) isValid;

-(void) reduce: (PositionCall*) pos;

-(BOOL) nextSolution;

-(PositionCall *) getAtY: (NSUInteger) row;

-(PositionCall *) getAtX: (NSUInteger) col Y: (NSUInteger) row;

-(void) removePosition: (PositionCall*) pos;

- (SolutionState) converge;

- (PositionCall *) positionAtIndex: (NSUInteger) index;

@end

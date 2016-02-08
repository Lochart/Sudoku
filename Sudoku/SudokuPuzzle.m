//
//  SudokuPuzzle.m
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "SudokuPuzzle.h"
#import "Solution.h"
#import "PositionCall.h"

@implementation SudokuPuzzle{
}

- (instancetype)initWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty {
    self = [super init];
    
    _solution = solution;
    _arena = [solution copy];
    _difficulty = difficulty;
    
    [self generate];
    
    return self;
}

-(void) generate{
    
    NSUInteger numbersToRemove = _difficulty + arc4random_uniform(3);
    
    NSMutableArray *available = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < 81; i++) {
        [available addObject:@(i)];
    }
    
    while (numbersToRemove > 0) {
        NSUInteger index = arc4random_uniform((uint32_t)available.count);
        NSNumber *arenapos = available[index];
        [available removeObjectAtIndex:index];
        
        PositionCall* pos = [_arena positionAtIndex:arenapos.unsignedIntegerValue];
        [self erasePosition: pos];
        
        numbersToRemove--;
    }
    
}

-(void) erasePosition: (PositionCall *) pos{
    pos.value = @(0);
}

@end

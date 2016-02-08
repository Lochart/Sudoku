//
//  SudokuGenerator.m
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "SudokuGenerator.h"
#import "Solution.h"
#import "SudokuPuzzle.h"

@implementation SudokuGenerator{
    NSMutableArray * _solutionStack;
};

- (instancetype) init {
    _solutionStack = [NSMutableArray new];
    return self;
};

- (Solution *) generateSolution: (Solution*) initialState {
    Solution *solution = nil;
    
    NSUInteger i = 0;
    while (i < 1) {
        
        NSUInteger backTrackCount = 0;
        solution = initialState ? initialState.copy : [Solution new];
        
        SolutionState state;
        [_solutionStack addObject:[solution copy]];
        
        do {
            state = [solution converge];
            switch (state) {
                case Solved:
                    NSLog(@"Puzzle solved!!! Backtrack count %lu", (unsigned long)backTrackCount);
                    //[solution printGrid];
                    [_solutionStack removeAllObjects];
                    break;
                case Progress:
                    [_solutionStack addObject:[solution copy]];
                    break;
                case Invalid:
                    solution = [_solutionStack lastObject];
                    if(![solution nextSolution]) {
                        [_solutionStack removeLastObject];
                        backTrackCount++;
                    } else {
                        solution = [solution copy];
                    }
                    break;
            }
            
        } while (state != Solved && solution);
        
        i++;
        
        if (solution == nil)
            NSLog(@"Backtrack count %lu", (unsigned long)backTrackCount);
    }
    
    return solution;
}

- (SudokuPuzzle *)generatePuzzleWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty {
    return [[SudokuPuzzle alloc] initWithSolution:solution difficulty: difficulty];
}

- (SudokuPuzzle *)generate: (PuzzleDifficulty) difficulty {
    Solution * solution = [self generateSolution: nil];
    SudokuPuzzle * puzzle = [self generatePuzzleWithSolution:solution difficulty: difficulty];
    
    return puzzle;
}


@end

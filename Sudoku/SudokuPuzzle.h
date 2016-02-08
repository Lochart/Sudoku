//
//  SudokuPuzzle.h
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Solution;

typedef NS_ENUM(NSInteger, PuzzleDifficulty){
    PuzzleDifficultyEasy = 30,
    PuzzleDifficultyMedium = 45,
    PuzzleDifficultyHard = 56
};

@interface SudokuPuzzle : NSObject

-(instancetype) initWithSolution: (Solution* ) solution difficulty: (PuzzleDifficulty) difficulty;

@property Solution* solution;

@property Solution* arena;

@property (readonly) PuzzleDifficulty difficulty;

@end

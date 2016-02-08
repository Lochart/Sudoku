//
//  SudokuGenerator.h
//  Sudoku
//
//  Created by Nikolay on 05.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SudokuPuzzle.h"

@class SudokuPuzzle;
@class Solution;

@interface SudokuGenerator : NSObject

-(Solution *) generateSolution: (Solution *) initialState;

-(SudokuPuzzle *) generatePuzzleWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulity;

-(SudokuPuzzle *) generate: (PuzzleDifficulty) difficulty;

@end

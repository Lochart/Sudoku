//
//  Solution.m
//  Sudoku
//
//  Created by Nikolay on 06.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "Solution.h"
#import "PositionCall.h"


@interface Solution ()

@property NSMutableArray * arena;
@property NSMutableArray * positions;
@property NSMutableArray * numbers;
@property NSMutableArray * menuNumbers;
@property NSUInteger popIndex;
@property NSUInteger valueIndex;

@end

@implementation Solution{
}

-(PositionCall *)getAtY:(NSUInteger)row{
    return _menuNumbers[row * 9];
}

-(PositionCall *) getAtX: (NSUInteger) col Y: (NSUInteger) row{
    return _arena[row * 9 + col];
}

- (PositionCall *) positionAtIndex: (NSUInteger) index{
    return _arena[index];
}


- (instancetype) init {
    [self generateStructs];
    return self;
}

- (instancetype)initSolutionWithArray:(NSArray *)arrayOfValues {
    self = [self init];
    
    NSUInteger i = 0;
    for (NSNumber* num in arrayOfValues) {
        PositionCall* pos = [self positionAtIndex:i];
        pos.value = num;
        i++;
    }
    
    self = [self initSolution];
    
    return self;
}

- (instancetype) initSolution {
    
    //initialize the solution internal state with a given partial solution already applied in the grid
    
    //construct the numbers that are possible in each row
    NSMutableArray *rowValues = [NSMutableArray array];
    
    for (NSUInteger row = 0; row < 9; row++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];
        
        NSArray* arrayOfPos = [self getRow:row];
        for (PositionCall * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }
        
        [rowValues addObject:set];
    }
    
    //construct the numbers that are possible in each column
    NSMutableArray *colValues = [NSMutableArray array];
    
    for (NSUInteger col = 0; col < 9; col++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];
        
        NSArray* arrayOfPos = [self getCol:col];
        for (PositionCall * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }
        
        [colValues addObject:set];
    }
    
    
    //construct the numbers that are possible in each grid
    NSMutableArray *arenaValues = [NSMutableArray array];
    
    for (NSUInteger arena = 0; arena < 9; arena++) {
        NSMutableSet *set = [NSMutableSet setWithArray:_numbers];
        
        NSArray* arrayOfPos = [self getArena:(arena / 3) * 3 col: (arena % 3) * 3];
        for (PositionCall * pos in arrayOfPos) {
            if (pos.value.integerValue != 0)
                [set removeObject:pos.value];
        }
        
        [arenaValues addObject:set];
    }
    
    //gather all of the incomplete position cells and initialize the possible values
    [_positions removeAllObjects];
    
    for (NSUInteger i = 0; i < 81; i++) {
        PositionCall * pos = [self positionAtIndex:i];
        
        [pos.possibleValues removeAllObjects];
        
        if (pos.value.integerValue == 0) {
            [_positions addObject: pos];
            
            NSMutableSet * set = [NSMutableSet setWithArray:_numbers];
            NSSet* rowSet = rowValues[pos.y];
            NSSet* colSet = colValues[pos.x];
            NSSet* gridSet = arenaValues[(pos.y / 3) * 3 + (pos.x / 3)];
            
            [set intersectSet:rowSet];
            [set intersectSet:colSet];
            [set intersectSet:gridSet];
            
            [pos.possibleValues addObjectsFromArray:set.allObjects];
            
        }
    }
    
    //sort positions by most constrained
    [_positions sortUsingComparator:[PositionCall comparator]];
    
    self.popIndex = 0;
    self.valueIndex = 0;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Solution * newSelf = [Solution new];
    newSelf.arena = [[NSMutableArray alloc]initWithArray:_arena copyItems:YES];
    newSelf.numbers = [[NSMutableArray alloc]initWithArray:_numbers copyItems:YES];
    newSelf.positions = [NSMutableArray new];
    
    //resolve the positions from the new grid
    for (PositionCall * p in _positions) {
        [newSelf.positions addObject:[newSelf getAtX:p.x Y:p.y]];
    }
    
    newSelf.popIndex = _popIndex;
    newSelf.valueIndex = _valueIndex;
    
    return newSelf;
}

- (void) generateStructs {
    NSUInteger i = 0;
    
    _popIndex = 0;
    _valueIndex = 0;
    _arena = [NSMutableArray new];
    _positions = [NSMutableArray new];
    _numbers = [NSMutableArray new];
    
    while (i++ < 9) {
        [_numbers addObject:@(i)];
    }
    
    i = 0;
    
    //generate the Position cells, a horizontal row at a time.
    while (i < 81) {
        PositionCall * pos = [[PositionCall alloc] initWithX: i % 9 Y: i / 9];
        [_positions addObject:pos];
        [_arena addObject:pos];
        i++;
    }
}

- (BOOL) nextSolution {
    //this method is called when the next most constrained cell most be chosen. The _valueIndex is incremented to choose
    // the next possible value.
    _valueIndex++;
    PositionCall* pos = [self getMostConstrained];
    return pos != nil && pos.possibleValues.count > _valueIndex;
}

- (SolutionState) converge {
    //find the most constrained position
    
    PositionCall * pos = nil;
    pos = [self getMostConstrained];
    
    if (pos != nil) {
        
        assert([_arena indexOfObject:pos] != NSNotFound);
        
        //get a random value from it's set
        pos.value = [self generateRandomValueFromPosition:pos];
        
        if (pos.value.integerValue != 0) {
            
            [self reduce:pos];
            
            //NSLog(@"x: %u y: %u", pos.x, pos.y);
            assert(pos.value.integerValue != 0);
            
            if ([self isValid]) {
                _valueIndex = 0;
                _popIndex = 0;
                return _positions.count == 0 ? Solved : Progress;
            }
        }
    }
    
    return Invalid;
}

- (BOOL) isValid {
    return _positions.count == 0 || [self getMostConstrained].possibleValues.count > 0;
}

- (void) checkAscending {
    int off = (int) _positions.count - 1;
    off--;
    while (off > 0) {
        PositionCall * pos0 = _positions[(NSUInteger) off];
        PositionCall * pos1 = _positions[(NSUInteger) off+1];
        
        assert(pos0.possibleValues.count <= pos1.possibleValues.count);
        
        off--;
        
    }
}

- (PositionCall *) getMostConstrained {
    PositionCall * retval = nil;
    if (_popIndex < _positions.count) {
        retval = _positions[_popIndex];
    }
    return retval;
}


- (void) removePosition: (PositionCall *) pos {
    //remove the last constrained position to make progress
    [_positions removeObject:pos];
    
    NSUInteger col = pos.x;
    NSUInteger row = pos.y;
    NSUInteger i = 0;
    
    NSArray *rowArr = [self getRow:row];
    NSArray *colArr = [self getCol:col];
    NSArray *gridArr = [self getArena:row col:col];
    
    //update the constrained positions
    while (i < 9) {
        [(PositionCall *) rowArr[i] remove:pos.value];
        [(PositionCall *) colArr[i] remove:pos.value];
        [(PositionCall *) gridArr[i] remove:pos.value];
        i++;
    }
    
    //sort positions by most constrained
    [_positions sortUsingComparator:[PositionCall comparator]];
}


-(BOOL) isValue: (NSNumber*) value inSet: (NSArray*) arrayOfPosition{
    for (NSUInteger i = 0; i < arrayOfPosition.count; i++) {
        PositionCall* posToTest = arrayOfPosition[i];
        if ([posToTest.value isEqualToNumber:value]) {
            return true;
        }
    }
    return  false;
}

-(void) reduce:(PositionCall *)pos{
    
    bool bCanReduceFurther;
    
    do {
        if (pos != nil)
            [self removePosition:pos];
        
        [self checkAscending];
        
        bCanReduceFurther = _positions.count > 0 && ((PositionCall *)_positions[0]).possibleValues.count == 1;
        
        if (bCanReduceFurther) {
            pos = _positions[0];
            pos.value = pos.possibleValues.lastObject;
        }
        
    } while (bCanReduceFurther);
    
}

-(NSNumber*) generateRandomValueFromPosition: (PositionCall*) pos{
    
    NSMutableArray* set = pos.possibleValues;
    NSNumber* value;
    
    if (_valueIndex < set.count) {
        value = set[_valueIndex];
    }
    
    return value;
}

-(NSArray*) getCol: (NSUInteger) col{
    NSMutableArray* array = [NSMutableArray new];
    
    NSUInteger i = 0;
    while (i < 9) {
        PositionCall* pos = _arena[i * 9 + col];
        [array addObject:pos];
        assert(pos.x == col);
        i++;
    }
    
    return array;
}

-(NSArray*) getRow: (NSUInteger) row{
    NSMutableArray* array = [NSMutableArray new];
    
    NSUInteger i = 0;
    while (i < 9) {
        PositionCall* pos = _arena[row * 9 + i];
        [array addObject:pos];
        assert(pos.y == row);
        i++;
    }
    
    return array;
}

-(NSArray*) getArena: (NSUInteger) row col: (NSUInteger) col{
    NSMutableArray* array = [NSMutableArray new];
    
    NSUInteger i = 0, j = 0;
    NSUInteger arenaOffSet = ((row / 3) * 3) * 9 + ((col / 3) * 3);
    while (i < 3) {
        j = 0;
        while (j < 3) {
            PositionCall* pos = _arena[arenaOffSet + (i * 9) + j];
            
            [array addObject:pos];
            j++;
        }
        i++;
    }
    
    return array;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:Solution.class]) {
        Solution* solution = object;
        for (NSUInteger i = 0; i < 81; i++) {
            if (((PositionCall*) _arena[i]).value != [solution positionAtIndex:i].value)
                return false;
        }
        return true;
    }
    return false;
}

@end

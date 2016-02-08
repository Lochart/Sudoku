//
//  ArenaViewController.m
//  Sudoku
//
//  Created by Nikolay on 24.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import "ArenaViewController.h"

#import "KnucleSelector.h"
#import "PositionCall.h"
#import "Solution.h"
#import "SudokuGenerator.h"

#import "ViewController.h"

@interface ArenaViewController ()

- (IBAction)menu:(id)sender;
- (IBAction)selectDifficulty:(id)sender;
- (IBAction)newGame:(id)sender;
- (IBAction)resetGame:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *timerDisplay;


@property (strong, nonatomic) UIView *arenaView;
@property (strong, nonatomic) UIView *numberView;

@property (nonatomic, getter=isSolutionVisible) BOOL solutionVisible;

@property (nonatomic) PuzzleDifficulty difficulty;
@property (strong, nonatomic) SudokuGenerator *generator;
@property (strong, nonatomic) SudokuPuzzle *puzzle;

@property (strong, nonatomic) NSMutableArray *knucles;
@property (nonatomic) NSTimer *roundTimer;

@end

const CGFloat xNumbersView = 20, yNumbersView = 10, widthNumbersView = 50, heightNumbersView = 30;
const CGFloat  xTopLine = 0, yTopLine = 3, widthTopLine = 9, heigtTopLine = 2;
const CGFloat  xBottomLine = 0, yBottomLine = 6, widthBottomLine = 9, heigtBottomLine = 2;
const CGFloat  xLeftLine = 3, yLeftLine = 0, widthLeftLine = 2, heigtLeftLine = 9;
const CGFloat  xRightLine = 6, yRightLine = 0, widthRightLine = 2, heigtRightLine = 9;


@implementation ArenaViewController

NSInteger secondTime;
NSInteger minutesTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arenaViewController];
    
}

-(void)arenaViewController{
    
 
    
    self.difficulty = PuzzleDifficultyEasy;
    self.generator = [[SudokuGenerator alloc] init];
    
    [self addKnucleMovementObserver];
    
    [self createArenaView];
    [self createNumbersView];
    
    [self createNumbersSelectorContent];
    
    [self newPuzzle];
    
    [self timeBeginRun];
    [self randomColorArenaView] ;
}

-(void)createArenaView{
    self.arenaView = [UIView new];
    
    CGRect rectArenaView = self.view.frame;
    
    rectArenaView.size.width -=10;
    rectArenaView.size.width = rectArenaView.size.height < rectArenaView.size.width ? rectArenaView.size.height / 2 : rectArenaView.size.width;
    rectArenaView.size.width -= (int) rectArenaView.size.width % 9;
    rectArenaView.size.width += 2;
    rectArenaView.size.height = rectArenaView.size.width;
    
    rectArenaView.origin.x +=(self.view.frame.size.width - rectArenaView.size.width) / 2;
    rectArenaView.origin.y += 20;
    
    self.arenaView.frame = rectArenaView;
    self.arenaView.layer.borderColor = [UIColor blackColor].CGColor;
    self.arenaView.layer.borderWidth = 2;
    
    [self.view addSubview:self.arenaView];
}

-(void)createNumbersView{
    self.numberView = [UIView new];
    
    self.numberView.frame = CGRectMake(xNumbersView,
                                       self.arenaView.frame.origin.y + self.arenaView.frame.size.height + yNumbersView,
                                       self.view.bounds.size.width - widthNumbersView,
                                       heightNumbersView);;
    
    
    self.numberView.backgroundColor = [UIColor yellowColor];
    self.numberView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.numberView.layer.borderWidth = 2;
    
    [self.view addSubview:self.numberView];
    
}

-(void)addKnucleMovementObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidDropKnucle:)
                                                 name:@"DidDropKnucle" object:nil];
}

-(void)userDidDropKnucle:(NSNotification *)n {
    
    NSDictionary *userInfo = n.userInfo;
    
    KnucleSelector *deoppendKnucle = userInfo[@"kKnucleKey"];
    
    UIView *arenaView = self.arenaView;
    
    CGPoint knucleCenterOnArena = [arenaView convertPoint:deoppendKnucle.center fromView:deoppendKnucle.superview];
    
    CGFloat knucleSize = arenaView.frame.size.width / 9.f;
    
    NSUInteger row = (NSUInteger)(knucleCenterOnArena.x / knucleSize);
    NSUInteger col = (NSUInteger)(knucleCenterOnArena.y / knucleSize);
    
    if (col <= 9 && col < 9 && row <= 9 && row < 9) {
        KnucleView *currentKnucle = self.knucles[col][row];
        
        if (currentKnucle.isEditable) {
            [currentKnucle setNumber:deoppendKnucle.number];

        }
    }

//    NSLog(@"col %lu row %i number %lu", (unsigned long)col , row, (unsigned long)deoppendKnucle.number);

}

- (void) newPuzzle {
    [self newPuzzleWithSolution:nil];
}

- (void) newPuzzleWithSolution: (Solution *) solution {
    SudokuPuzzle* puzzle = nil;
    
    if (solution == nil)
        puzzle = [self.generator generate: self.difficulty];
    else
        puzzle = [self.generator generatePuzzleWithSolution:solution difficulty: self.difficulty];
    
    self.puzzle = puzzle;
    
    for (UIView* view in self.arenaView.subviews)
        [view removeFromSuperview];
    
    [self layoutArena: self.solutionVisible ? self.puzzle.solution : self.puzzle.arena];
}

-(void) layoutArena: (Solution*) solutionToShow{
    
    NSMutableArray *knucles = [NSMutableArray arrayWithCapacity:9];
    
    CGRect rect = self.arenaView.frame;
    
    CGFloat sizeOfSquares = (rect.size.width - 2) / 9;
    
    //rows
    for (NSUInteger i = 0; i < 9; i++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:9];
        //cols
        for (NSUInteger j = 0; j < 9; j++) {
            PositionCall *pos = [solutionToShow getAtX:j Y:i];
            
            KnucleView *image = [KnucleView knuckeWithNumber: pos.value.unsignedIntegerValue];
            
            rect = CGRectMake(j * sizeOfSquares, i * sizeOfSquares, sizeOfSquares + 2, sizeOfSquares + 2);
            
            image.frame = rect;
            
            image.layer.borderColor = [UIColor whiteColor].CGColor;
            image.layer.borderWidth = 2;
            
            [self.arenaView addSubview:image];
            
            [row addObject:image];
        }
        [knucles addObject:row];
    }
    
    [self setKnucles:knucles];
    
    
    
    [self dreawArenaLines:rect sizeOfSquares:(int) sizeOfSquares];
}

//Draws the grid inside the arena with four UILabel
-(void) dreawArenaLines: (CGRect) rect sizeOfSquares: (NSInteger) sizeOfSquares{
    
    UIView* topLine = [UILabel new];
    rect = CGRectMake(xTopLine, sizeOfSquares * yTopLine, sizeOfSquares * widthTopLine + 2, heigtTopLine);
    topLine.frame = rect;
    topLine.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.arenaView addSubview:topLine];
    
    UIView* bottomLine = [UILabel new];
    rect = CGRectMake(xBottomLine, sizeOfSquares * yBottomLine, sizeOfSquares * widthBottomLine + 2, heigtBottomLine);
    bottomLine.frame = rect;
    bottomLine.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.arenaView addSubview:bottomLine];
    
    UIView* leftLine = [UILabel new];
    rect = CGRectMake(sizeOfSquares * xLeftLine, yLeftLine, widthLeftLine, sizeOfSquares * heigtLeftLine + 2);
    leftLine.frame = rect;
    leftLine.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.arenaView addSubview:leftLine];
    
    UIView* rightLine = [UILabel new];
    rect = CGRectMake(sizeOfSquares * xRightLine, yRightLine, widthRightLine, sizeOfSquares * heigtRightLine + 2);
    rightLine.frame = rect;
    rightLine.layer.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.arenaView addSubview:rightLine];
}


- (void)createNumbersSelectorContent
{
    UIView *targetView = self.numberView;
    
    CGRect rect = targetView.bounds;
    
    CGFloat knucleWidth = CGRectGetHeight(rect);
    rect.size = CGSizeMake(knucleWidth, knucleWidth);
    
    //row
    for (NSUInteger i = 1; i <= 9; i++) {
        
        KnucleSelector *menuNumber = [KnucleSelector knuckeWithNumber:i];
        [menuNumber setFrame:rect];
        [menuNumber setTargetView:self.view];
        
        menuNumber.layer.borderColor = [UIColor whiteColor].CGColor;
        menuNumber.layer.borderWidth = 1;
        
        [targetView addSubview:menuNumber];
        
        rect.origin.x += knucleWidth;
    }
}

- (void) randomColorArenaView {
    
    UIColor *colors = [UIColor new];
    CGFloat red, blue, green;
    red =  (CGFloat)arc4random() * rand()/(CGFloat)RAND_MAX;
    blue = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    green = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    
    if (red > 10 || blue > 10 || green > 10 || red < 245 || blue < 245 || green < 245 ) {
        red = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
        blue = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
        green = (CGFloat)arc4random()/(CGFloat)RAND_MAX;
    }
    
    colors = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    self.view.backgroundColor = colors;
}

- (IBAction)newGame:(id)sender {
    
    self.solutionVisible = NO;
    [self newPuzzle];
    [self resetTime];
    [self randomColorArenaView];
}

- (IBAction)resetGame:(id)sender {
    
    for (UIView* view in _arenaView.subviews)
        [view removeFromSuperview];
    
    [self layoutArena: self.solutionVisible ? self.puzzle.solution : self.puzzle.arena];
    [self resetTime];
    [self randomColorArenaView] ;
}

- (IBAction)selectDifficulty:(id)sender {
    
    UIActionSheet *menu = [[UIActionSheet alloc]initWithTitle:@"Select difficulty"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Easy",@"Medium",@"Hard", nil];
    
    [menu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //difficulty level was chosen
    PuzzleDifficulty difficulty = self.difficulty;
    
    switch (buttonIndex) {
        case 0:
            self.difficulty = PuzzleDifficultyEasy;
            [self randomColorArenaView];
            [self resetTime];
            break;
        case 1:
            self.difficulty = PuzzleDifficultyMedium;
            [self randomColorArenaView];
            [self resetTime];
            break;
        case 2:
            self.difficulty = PuzzleDifficultyHard;
            [self randomColorArenaView];
            [self resetTime];
            break;
    }
    
    if (difficulty != self.difficulty)
        [self newPuzzleWithSolution:self.puzzle.solution];
}


-(IBAction)myUnwindAction:(UIStoryboardSegue *)unwindSegue{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                     fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    return self;
}

- (IBAction)menu:(id)sender {
    [self endTime];
}

-(void)timeBeginRun
{
    self.roundTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateTime)
                                                     userInfo:nil
                                                      repeats:YES];
}

-(void)updateTime
{
    secondTime += 1;
    if (secondTime >=60) {
        secondTime = 0;
        minutesTime +=1;
    }
    
    self.timerDisplay.text = [NSString stringWithFormat:@"%02ld:%02ld",
                              (unsigned long)minutesTime,
                              (unsigned long)secondTime];
}

-(void)resetTime
{
    secondTime = 0;
    self.timerDisplay.text = [NSString stringWithFormat:@"00:00"];
}

-(void)endTime
{
    [self.roundTimer invalidate ];
    secondTime = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

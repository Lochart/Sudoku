//
//  KnucleViewViewController.h
//  Sudoku
//
//  Created by Nikolay on 23.11.15.
//  Copyright © 2015 Nikolay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KnucleView : UIImageView <NSCopying>

@property (nonatomic) NSUInteger number;
@property (nonatomic, readonly, getter=isEditable) BOOL editable;

+ (instancetype)knuckeWithNumber:(NSUInteger)number;

@end

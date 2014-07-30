//
//  KLBViewController.h
//  iTennis
//
//  Created by Chase Gosingtian on 7/28/14.
//  Copyright (c) 2014 KLab Cyscorpions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLBViewController : UIViewController
{
    IBOutlet UIImageView *ball;
    IBOutlet UIImageView *racketYellow;
    IBOutlet UIImageView *racketGreen;
    IBOutlet UILabel *tapToBegin;
    IBOutlet UILabel *playerScore;
    IBOutlet UILabel *computerScore;
    
    CGPoint ballVelocity;
    NSInteger gameState;
    
    bool scored;
}

@property (nonatomic,retain) IBOutlet UIImageView *ball;
@property (nonatomic,retain) IBOutlet UIImageView *racketYellow;
@property (nonatomic,retain) IBOutlet UIImageView *racketGreen;
@property (nonatomic,retain) IBOutlet UILabel *tapToBegin;
@property (nonatomic,retain) IBOutlet UILabel *playerScore;
@property (nonatomic,retain) IBOutlet UILabel *computerScore;

@property (nonatomic) CGPoint ballVelocity;
@property (nonatomic) NSInteger gameState;

@property (nonatomic) bool scored;

- (void)dealloc;
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;
- (void)gameLoop;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)runBasicAI;
- (float)difficultySpeedModify:(float)val;
- (void)scoreUpdate;
- (void)endGameCheck:(BOOL)newGame;

@end

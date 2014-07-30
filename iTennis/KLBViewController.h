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
}

@property (nonatomic,retain) IBOutlet UIImageView *ball;
@property (nonatomic,retain) IBOutlet UIImageView *racketYellow;
@property (nonatomic,retain) IBOutlet UIImageView *racketGreen;
@property (nonatomic,retain) IBOutlet UILabel *tapToBegin;
@property (nonatomic,retain) IBOutlet UILabel *playerScore;
@property (nonatomic,retain) IBOutlet UILabel *computerScore;

@property (nonatomic) CGPoint ballVelocity;
@property (nonatomic) NSInteger gameState;

- (void)dealloc;

@end

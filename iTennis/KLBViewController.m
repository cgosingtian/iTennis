//
//  KLBViewController.m
//  iTennis
//
//  Created by Chase Gosingtian on 7/28/14.
//  Copyright (c) 2014 KLab Cyscorpions, Inc. All rights reserved.
//

#import "KLBViewController.h"
#import "KLBConstants.h"

//@interface KLBViewController ()
//
//@end

@implementation KLBViewController

@synthesize ball,
            racketYellow,
            racketGreen,
            tapToBegin,
            playerScore,
            computerScore,
            ballVelocity,
            gameState,
            scored;

- (void)dealloc
{
    [super dealloc];
    [ball release];
    [racketYellow release];
    [racketGreen release];
    [playerScore release];
    [tapToBegin release];
    [computerScore release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setGameState:KLB_GAME_STATE_PAUSED];
    [self setBallVelocity:CGPointMake(KLB_BALL_SPEED_X, KLB_BALL_SPEED_Y)];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gameLoop
{
    if (gameState == KLB_GAME_STATE_RUNNING)
    {
        [ball setCenter:CGPointMake([ball center].x + ballVelocity.x, [ball center].y + ballVelocity.y)];
        
        if ([ball center].x > [[self view] bounds].size.width || [ball center].x < 0)
        {
            ballVelocity.x = -ballVelocity.x;
        }
        
        if ([ball center].y > [[self view] bounds].size.height || [ball center].y < 0)
        {
            ballVelocity.y = -ballVelocity.y;
            scored = false;
        }
        
        //collision detection
        if (CGRectIntersectsRect([ball frame], [racketYellow frame]))
        {
//            if ([ball center].y > [racketYellow center].y) // if ball in-front of racket
            if (ballVelocity.y > 0) // if ball is moving towards racket
            {
                ballVelocity.y = -ballVelocity.y; //reverse Y aka hit it back
            }
        }
        
        if (CGRectIntersectsRect([ball frame], [racketGreen frame]))
        {
//            if ([ball center].y > [racketGreen center].y) // if ball in-front of racket
            if (ballVelocity.y < 0) // if ball is moving towards racket
            {
                ballVelocity.y = -ballVelocity.y; //reverse Y aka hit it back
            }
        }
        
        [self runBasicAI];
        [self scoreUpdate];
    }
    else
    {
        if ([tapToBegin isHidden])
        {
            [tapToBegin setHidden:NO];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self gameState] == KLB_GAME_STATE_PAUSED)
    {
        [tapToBegin setHidden:YES];
        [self setGameState:KLB_GAME_STATE_RUNNING];
    }
    else if ([self gameState] == KLB_GAME_STATE_RUNNING)
    {
        [self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    CGPoint xLocation = CGPointMake(location.x, [racketYellow center].y); //x of touch, but limit Y to racket Y
    [racketYellow setCenter:xLocation];
}

#pragma mark - AI methods

- (void)runBasicAI
{
    // just try to match the x coordinate of the ball, but throttle speed based on distance between ball and racket
    CGFloat xDistance = [racketGreen center].x - [ball center].x;
    
    if ([racketGreen center].x > [ball center].x)
    {
        if (xDistance > KLB_COM_MOVE_SPEED)
        {
            [racketGreen setCenter:CGPointMake(([racketGreen center].x-[self difficultySpeedModify:KLB_COM_MOVE_SPEED]), [racketGreen center].y)];
        }
        else
        {
            [racketGreen setCenter:CGPointMake(([racketGreen center].x-[self difficultySpeedModify:xDistance]), [racketGreen center].y)];
        }
    }
    else if ([racketGreen center].x < [ball center].x)
    {
        if (xDistance < KLB_COM_MOVE_SPEED)
        {
            [racketGreen setCenter:CGPointMake(([racketGreen center].x+[self difficultySpeedModify:KLB_COM_MOVE_SPEED]), [racketGreen center].y)];
        }
        else
        {
            [racketGreen setCenter:CGPointMake(([racketGreen center].x+[self difficultySpeedModify:xDistance]), [racketGreen center].y)];
        }
    }
}

-(float)difficultySpeedModify:(float)val //apply a random percentage reduction on the value
{
    NSLog(@"%f",(val - (val * (arc4random_uniform(25)/100.0))));
    return (val - (val * (arc4random_uniform(25)/100.0)));
}

- (void)scoreUpdate
{
    if (!scored)
    {
        if ([ball center].y <= 0)
        {
            NSInteger p = [[playerScore text] intValue];
            [playerScore setText:[NSString stringWithFormat:@"%d",++p]];
        }
        else if ([ball center].y >= [[UIScreen mainScreen] bounds].size.height)
        {
            NSInteger comp = [[computerScore text] intValue];
            [computerScore setText:[NSString stringWithFormat:@"%d",++comp]];
        }
        scored = true;
    }
}

@end

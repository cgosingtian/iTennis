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
            touchedLocation,
            scored,
            racketTouched;

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
        
        [self movePlayer];
        
        [self runBasicAI];
        [self scoreUpdate];
    }
    else
    {
        if (gameState == KLB_GAME_STATE_NEW_GAME)
        {
            [ball setCenter:[[self view] center]];
            [self setGameState:KLB_GAME_STATE_RUNNING];
            [tapToBegin setHidden:YES];
        }
        else if ([tapToBegin isHidden])
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
        [self setGameState:KLB_GAME_STATE_NEW_GAME];
    }
    else if ([self gameState] == KLB_GAME_STATE_RUNNING)
    {
        [self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    //CGPoint location = [touch locationInView:[touch view]];
    touchedLocation = [touch locationInView:[touch view]];
    //CGPoint xLocation = CGPointMake(location.x, [racketYellow center].y); //x of touch, but limit Y to racket Y
    //[racketYellow setCenter:xLocation];
    
    racketTouched=true;
}

- (CGPoint)generateMoveTowardsCoordinates:(CGPoint)source WithDestination:(CGPoint)destination WithSpeed:(NSUInteger)speed YCoordinateLocked:(bool)yLock
{
    CGFloat xTowards = 0,
            yTowards = 0;
    if (destination.x > source.x)
    {
        xTowards = source.x + speed;
        if (xTowards > destination.x)
            xTowards = destination.x;
    }
    else
    {
        xTowards = source.x - speed;
        if (xTowards < destination.x)
            xTowards = destination.x;
    }
    
    if (yLock)
    {
        yTowards = source.y;
    }
    else {
        if (destination.y > source.y)
        {
            yTowards = source.y + speed;
            if (yTowards > destination.y)
                yTowards = destination.y;
        }
        else
        {
            yTowards = source.y - speed;
            if (yTowards < destination.y)
                yTowards = destination.y;
        }
    }
    
    return CGPointMake(xTowards, yTowards);
}

- (void)movePlayer
{
    if (racketTouched)
    {
        [racketYellow setCenter:[self generateMoveTowardsCoordinates:[racketYellow center] WithDestination:touchedLocation WithSpeed:KLB_PLAYER_MOVE_SPEED YCoordinateLocked:true]];
        
        if (CGPointEqualToPoint([racketYellow center], touchedLocation))
        {
            racketTouched=false;
        }
    }
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
//    NSLog(@"%f",(val - (val * (arc4random_uniform(25)/100.0))));
    return (val - (val * (arc4random_uniform(25)/100.0))); //35 is too easy
}

- (void)scoreUpdate
{
    if (!scored)
    {
        if ([ball center].y <= 0)
        {
            NSInteger p = [[playerScore text] intValue];
            [playerScore setText:[NSString stringWithFormat:@"%d",++p]];
            [self endGameCheck:(p >= KLB_SCORE_TO_WIN)];
        }
        else if ([ball center].y >= [[UIScreen mainScreen] bounds].size.height)
        {
            NSInteger comp = [[computerScore text] intValue];
            [computerScore setText:[NSString stringWithFormat:@"%d",++comp]];
            [self endGameCheck:(comp >= KLB_SCORE_TO_WIN)];
        }
        scored = true;
    }
}

- (void)endGameCheck:(BOOL)newGame
{
    if (newGame)
    {
        [self setGameState:KLB_GAME_STATE_PAUSED];
        
        if ([[playerScore text] intValue] > [[computerScore text] intValue])
        {
            [tapToBegin setText:[NSString stringWithFormat:@"Player wins! %d - %d",[[playerScore text] intValue],[[computerScore text] intValue]]];
        }
        else
        {
            [tapToBegin setText:[NSString stringWithFormat:@"Computer wins! %d - %d",[[computerScore text] intValue],[[playerScore text] intValue]]];
        }
        [playerScore setText:[NSString stringWithFormat:@"%d",0]];
        [computerScore setText:[NSString stringWithFormat:@"%d",0]];
    }
//    else
//    {
//        [tapToBegin setText:@"Tap to begin!"];
//        [self setGameState:KLB_GAME_STATE_PAUSED];
//        [ball setCenter:[[self view] center]];
//    }
}

@end

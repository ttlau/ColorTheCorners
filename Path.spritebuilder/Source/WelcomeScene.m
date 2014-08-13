//
//  WelcomeScene.m
//  Path
//
//  Created by Tim Lau on 8/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WelcomeScene.h"

@implementation WelcomeScene

-(void)didLoadFromCCB{
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    
    self.userInteractionEnabled = FALSE;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(enableTouch:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GoalScene"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition: [CCTransition transitionCrossFadeWithDuration:.5]];
}

-(void)enableTouch: (NSTimer*)timer{
    self.userInteractionEnabled = TRUE;
    
}


@end

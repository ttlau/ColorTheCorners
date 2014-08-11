//
//  GoalScene.m
//  Path
//
//  Created by Tim Lau on 8/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GoalScene.h"

@implementation GoalScene

-(void)didLoadFromCCB{
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(nextScreen:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)nextScreen: (NSTimer*)timer{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition: [CCTransition transitionCrossFadeWithDuration:.5]];
    
}

@end

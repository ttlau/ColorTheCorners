//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "UIColor+HTColor.h"

@implementation MainScene{
    HTPressableButton *playButton;
    HTPressableButton *resetButton;
    
}

-(void)didLoadFromCCB{
    
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
    
    CCLabelTTF *message;
    message = [[CCLabelTTF alloc] initWithString:@"Color The Corners" fontName: @"HelveticaNeue-Light" fontSize:60];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/4*3)];
    [self addChild:message];
}

-(void)onEnterTransitionDidFinish{
    
    [super onEnterTransitionDidFinish];
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = CGRectMake([thisDirector viewSize].width/2 - 50, [thisDirector viewSize].height/2 + 5, 112.5, 55);
    playButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.buttonColor = [UIColor ht_sunflowerColor];
    playButton.shadowColor = [UIColor ht_citrusColor];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame3 = CGRectMake([thisDirector viewSize].width/2 - 50, [thisDirector viewSize].height/2 + 73.5, 112.5, 55);
    resetButton = [[HTPressableButton alloc] initWithFrame:frame3 buttonStyle:HTPressableButtonStyleRounded];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    resetButton.buttonColor = [UIColor ht_sunflowerColor];
    resetButton.shadowColor = [UIColor ht_citrusColor];
    [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: playButton];
    [[[CCDirector sharedDirector] view]addSubview: resetButton];
}

- (void)play {
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    CCScene *gameplayScene;
    CCTransition *transition;
    if ([currentLevel intValue] == 1){
        gameplayScene = [CCBReader loadAsScene:@"WelcomeScene"];
        transition = [CCTransition transitionCrossFadeWithDuration:0.5f];
    }
    else{
        gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
        transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:1];
    }
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition: transition];
    [playButton removeFromSuperview];
    [resetButton removeFromSuperview];
}

-(void)reset{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:1] forKey:@"userLevel"];
}

@end

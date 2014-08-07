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
    message = [[CCLabelTTF alloc] initWithString:@"Welcome!" fontName: @"Papyrus" fontSize:25];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/2)];
    [self addChild:message];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = CGRectMake([thisDirector viewSize].width/2 - 37.5, [thisDirector viewSize].height/2 + 47.5, 75, 35);
    playButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.buttonColor = [UIColor ht_sunflowerColor];
    playButton.shadowColor = [UIColor ht_citrusColor];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame3 = CGRectMake([thisDirector viewSize].width/2 - 37.5, [thisDirector viewSize].height/2 + 87.5, 75, 35);
    resetButton = [[HTPressableButton alloc] initWithFrame:frame3 buttonStyle:HTPressableButtonStyleRounded];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    resetButton.buttonColor = [UIColor ht_sunflowerColor];
    resetButton.shadowColor = [UIColor ht_citrusColor];
    [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: playButton];
    [[[CCDirector sharedDirector] view]addSubview: resetButton];
}

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    [playButton removeFromSuperview];
    [resetButton removeFromSuperview];
}

-(void)reset{
    [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:0] forKey:@"userLevel"];
}

@end

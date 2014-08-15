//
//  FailScene.m
//  Path
//
//  Created by Tim Lau on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SuccessScene.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "UIColor+HTColor.h"


@implementation SuccessScene{
    HTPressableButton *clearButton;
}

-(void)didLoadFromCCB{
    
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
    
    CCLabelTTF *message;
    message = [[CCLabelTTF alloc] initWithString:@"Good Job!" fontName: @"HelveticaNeue-Light" fontSize:60];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/4*3-20.5)];
    [self addChild:message];
}

-(void)onEnterTransitionDidFinish{
    
    [super onEnterTransitionDidFinish];
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = IS_PAD?CGRectMake(512-100, 384+125, 225, 110):CGRectMake([thisDirector viewSize].width/2 - 65, [thisDirector viewSize].height/2 + 25, 112.5, 55);
    clearButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [clearButton setTitle:@"Continue" forState:UIControlStateNormal];
    clearButton.buttonColor = [UIColor ht_sunflowerColor];
    clearButton.shadowColor = [UIColor ht_citrusColor];
    [clearButton addTarget:self action:@selector(continue) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: clearButton];

}

- (void)continue {
    
    [clearButton removeFromSuperview];
    
    // reload this level
    CCScene *mainScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]];
}

@end

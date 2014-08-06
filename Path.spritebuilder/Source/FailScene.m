//
//  FailScene.m
//  Path
//
//  Created by Tim Lau on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FailScene.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "UIColor+HTColor.h"


@implementation FailScene{
    HTPressableButton *clearButton;
}

-(void)didLoadFromCCB{
    
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: 0.906 green: 0.298 blue: 0.235];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: .906 green: .467 blue: .235];
    
    CCLabelTTF *message;
    message = [[CCLabelTTF alloc] initWithString:@"Aww try again" fontName: @"Helvetica" fontSize:15];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/2)];
    [self addChild:message];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = CGRectMake([thisDirector viewSize].width/2 - 32.5, [thisDirector viewSize].height/2 + 47.5, 65, 35);
    clearButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [clearButton setTitle:@"Retry" forState:UIControlStateNormal];
    clearButton.buttonColor = [UIColor ht_sunflowerColor];
    clearButton.shadowColor = [UIColor ht_citrusColor];
    [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: clearButton];
    
}

- (void)clear {
    // reload this level
    [[CCDirector sharedDirector] popScene];
    [clearButton removeFromSuperview];
}

@end

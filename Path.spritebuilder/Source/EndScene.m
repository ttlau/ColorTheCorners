//
//  EndScene.m
//  Path
//
//  Created by Tim Lau on 8/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "EndScene.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "UIColor+HTColor.h"

@implementation EndScene{
    HTPressableButton *homeButton;
}

-(void)didLoadFromCCB{
    
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
    
    CCLabelTTF *message;
    message = [[CCLabelTTF alloc] initWithString:@"Thank You for Playing!" fontName: @"Papyrus" fontSize:25];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/2)];
    [self addChild:message];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = CGRectMake([thisDirector viewSize].width/2 - 32.5, [thisDirector viewSize].height/2 + 47.5, 105, 35);
    homeButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [homeButton setTitle:@"Return Home" forState:UIControlStateNormal];
    homeButton.buttonColor = [UIColor ht_sunflowerColor];
    homeButton.shadowColor = [UIColor ht_citrusColor];
    [homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: homeButton];
    
}

- (void)home {
    // reload this level
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
    [homeButton removeFromSuperview];
}


@end

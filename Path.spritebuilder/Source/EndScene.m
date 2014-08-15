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
    HTPressableButton *learnMoreButton;
}

-(void)didLoadFromCCB{
    
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed: .275 green: .537 blue: .4];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: 1 green: .941 blue: .647];
    
    CCLabelTTF *message;
    message = [[CCLabelTTF alloc] initWithString:@"Thank You for Playing!" fontName: @"HelveticaNeue-Light" fontSize:50];
    [message setPosition: CGPointMake([thisDirector viewSize].width/2, [thisDirector viewSize].height/2 + 55)];
    [self addChild:message];
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    
    CCDirector *thisDirector = [CCDirector sharedDirector];
    
    //note: for the x coordinate, take the width of the button + displacement from side and then minus width
    CGRect frame2 = IS_PAD?CGRectMake(512-100, 384+150, 225, 110):CGRectMake([thisDirector viewSize].width/2 - 50, [thisDirector viewSize].height/2 + 73.5, 112.5, 55);
    homeButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [homeButton setTitle:@"Home" forState:UIControlStateNormal];
    homeButton.buttonColor = [UIColor ht_sunflowerColor];
    homeButton.shadowColor = [UIColor ht_citrusColor];
    [homeButton addTarget:self action:@selector(home) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame3 = IS_PAD?CGRectMake(512-135, 384, 300, 110):CGRectMake([thisDirector viewSize].width/2 - 50, [thisDirector viewSize].height/2 + 5, 112.5, 55);
    learnMoreButton = [[HTPressableButton alloc] initWithFrame:frame3 buttonStyle:HTPressableButtonStyleRounded];
    [learnMoreButton setTitle:@"Learn More" forState:UIControlStateNormal];
    learnMoreButton.buttonColor = [UIColor ht_sunflowerColor];
    learnMoreButton.shadowColor = [UIColor ht_citrusColor];
    [learnMoreButton addTarget:self action:@selector(learnMore) forControlEvents:UIControlEventTouchUpInside];
    
    [[[CCDirector sharedDirector] view]addSubview: homeButton];
    [[[CCDirector sharedDirector] view]addSubview: learnMoreButton];

    
}

- (void)home {
    // reload this level
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1]];
    [homeButton removeFromSuperview];
    [learnMoreButton removeFromSuperview];
}

-(void)learnMore{
    
    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://en.wikipedia.org/wiki/Graph_coloring" ];
    [[UIApplication sharedApplication] openURL:url];
    
}


@end

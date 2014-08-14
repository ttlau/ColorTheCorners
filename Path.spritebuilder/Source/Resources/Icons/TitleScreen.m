//
//  TitleScreen.m
//  Path
//
//  Created by Tim Lau on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "TitleScreen.h"

@implementation TitleScreen

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end

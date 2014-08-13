//
//  Vertex.m
//  Path
//  Purpose of this class is to act as the "invisible" node where colors of the vertices are tracked
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//  vertex does own blinking, update method, true/false isBlinking, call itself etc. 
//

#import "Vertex.h"

@implementation Vertex

-(id)init{
    self = [super init];
    self.isConnected = FALSE;
    self.isFlashing = FALSE;
    return self;
}

- (void)pulse
{
    if (self.isFlashing && self.color.red == 0 && self.color.green == 0 && self.color.blue == 0){
        [self setOpacity:1.0];
        CCActionFadeTo *fadeIn = [CCActionFadeTo actionWithDuration:0.5 opacity:0.2];
        CCActionFadeTo *fadeOut = [CCActionFadeTo actionWithDuration:0.5 opacity:1];
    
        CCActionSequence *pulseSequence = [CCActionSequence actionOne:fadeIn two:fadeOut];
        [self runAction:pulseSequence];
        [NSTimer
         scheduledTimerWithTimeInterval:(NSTimeInterval)(1.5)
         target:self
         selector:@selector(pulse)
         userInfo:nil
         repeats:false];

    }
    else{
        [self stopAllActions];
        [self setOpacity:1.0];
        self.isFlashing = FALSE;
    }
}

@end

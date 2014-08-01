//
//  Vertex.m
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Vertex.h"

//TODO: Start and Finish vertex implementation

@implementation Vertex

-(id)init{
    self = [super init];
    if (self){
        self.color = [CCColor redColor];
    }
    self.isConnected = FALSE;
    return self;
}

@end

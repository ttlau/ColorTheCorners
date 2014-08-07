//
//  Vertex.m
//  Path
//  Purpose of this class is to act as the "invisible" node where colors of the vertices are tracked
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

-(id)init{
    self = [super init];
    if (self){
        self.color = [CCColor blackColor];
    }
    self.isConnected = FALSE;
    return self;
}

@end

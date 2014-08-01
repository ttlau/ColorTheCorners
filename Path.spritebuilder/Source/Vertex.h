//
//  Vertex.h
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Tim Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSprite.h"

@interface Vertex : CCSprite{
    NSSet *linkedNodes;
}

@property (nonatomic, assign) int tag;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, retain) NSSet *linkedNodes;

@end

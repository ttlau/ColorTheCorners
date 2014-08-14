//
//  Gameplay.m
//  Path
//
//  Created by Tim Lau on 7/14/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
// TODO: tutorials - bigger text, placement, call to action (now you finish!), the actual goal in the beginning, animations
// ask - transparent flashing screen, and rounded buttons, and z order of vertices
//

#import "Gameplay.h"
#import "Vertex.h"
#import"ColorSelector.h"
#import "HTPressableButton-master/Classes/HTPressableButton.h"
#import "HTPressableButton-master/Classes/UIColor+HTColor.h"


@implementation Gameplay{
    
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCLabelTTF *tutorialText;
    
    
    NSMutableArray *_listOfVertices;
    NSMutableArray *colors;
    
    int numOfColors;
    CCColor *currentColor;
    
    CCLayoutBox *colorBox;
    
    CCSprite *highlighter;
    
    int numOfVertices;
    int numVerticesColored;
    
    CCButton *backButton;
    CCButton *clearButton;
    
    int userLevel;
    
    CCNodeColor *flashView;
    
    CCActionBlink *blinkAction;
    
}

-(void)onEnter{
    
    [super onEnter];
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    //set the points to number of colors left
    //_scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    
    //set the number of vertices uncolored to num of vertices
    numOfVertices = [_listOfVertices count];
    numVerticesColored = 0;
    
    if (userLevel == 1){
        [self presentWelcome];
    }

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    
    
    NSNumber *currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    userLevel = [currentLevel intValue];
    
    // if currentLevel returns nil, set to the first level
    if (currentLevel == nil)
    {
        userLevel = 1;
        [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
        currentLevel = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLevel"];
    }
    
    // load the level
    CCNode *level = [CCBReader load: [NSString stringWithFormat:@"Levels/Level%d",[currentLevel intValue]]];
    [_levelNode addChild:level];
    
    
    // initialize variables
    _listOfVertices = [[NSMutableArray alloc] init];
    colors = [[NSMutableArray alloc] init];

#pragma mark populate list of vertices
    
    CCNode *_levelNodeChild = [_levelNode.children objectAtIndex:0];
    CCNode *_listOfSprites = [_levelNodeChild.children objectAtIndex:1];
    

    // for tag numbers
    int tagNumber = 0;
    
    for (Vertex *s in _listOfSprites.children){
        
        // set properties
        s.tag = tagNumber;
        s.color = [CCColor blackColor];
        s.isConnected = FALSE;
        s.isFlashing = FALSE;
        // s.visible = FALSE;
        
        
//        // demonstrate number in array
//        CCLabelTTF *tagString;
//        tagString = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d", tagNumber] fontName: @"Helvetica" fontSize:15];
//        [tagString setPosition: s.positionInPoints];
//        [_levelNode addChild:tagString];
          tagNumber++;
        
        // add to list of vertices
        [_listOfVertices addObject: s];
    }
    
#pragma mark draw the edges
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Level Properties" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *levelProperties = [levels objectForKey:[NSString stringWithFormat:@"Level%d", [currentLevel intValue]]];
    NSArray *edges = [levelProperties objectForKey:@"Edges"];
    
    
    // create dots
    CCDrawNode *map;
    map = [[CCDrawNode alloc]init];
    map.position = (ccp(0,0));
    CCNode *_lineNode = [_levelNodeChild.children objectAtIndex:0];
    [_lineNode addChild:map];
    
    int index = 0;
    int secondIndex = 0;
    
    
    while (index < [edges count])
    {
        secondIndex = 0;
        NSMutableArray *childrenOfVertex = [[NSMutableArray alloc] init];
        // because the adjacency matrix is symmetric, no need to double draw
        while(secondIndex < index)
        {
            if ([(NSNumber*)edges[index][secondIndex] isEqualToNumber:@1])
            {
                [map drawSegmentFrom:((Vertex*)[_listOfVertices objectAtIndex:index]).positionInPoints to:((Vertex*)[_listOfVertices objectAtIndex:secondIndex]).positionInPoints radius:4.0 color:[CCColor colorWithRed:0.925 green:0.941 blue:0.945]];
                [map setZOrder:0];
                
                // second index are things that are connected to current vertex, with current vertex as origin point
                [childrenOfVertex addObject: _listOfVertices[secondIndex]];
            }
            secondIndex++;
        }
        // assign current vertex's linked nodes to temp array above
        ((Vertex *)_listOfVertices[index]).linkedNodes = [[NSSet alloc] initWithArray: childrenOfVertex];
        index++;
    }

#pragma mark draw the color options
    NSArray *possibleColors = @[[CCColor colorWithUIColor: [UIColor ht_alizarinColor]], [CCColor colorWithUIColor: [UIColor ht_carrotColor]], [CCColor colorWithUIColor: [UIColor ht_sunflowerColor]], [CCColor colorWithUIColor: [UIColor ht_emeraldColor]], [CCColor colorWithUIColor: [UIColor ht_blueJeansColor]], [CCColor colorWithUIColor: [UIColor ht_amethystColor]], [CCColor colorWithUIColor: [UIColor ht_pinkRoseColor]], [CCColor colorWithUIColor: [UIColor ht_bitterSweetColor]], [CCColor colorWithUIColor: [UIColor ht_lemonColor]], [CCColor colorWithUIColor: [UIColor ht_grassColor]], [CCColor colorWithUIColor: [UIColor ht_jayColor]], [CCColor colorWithUIColor: [UIColor ht_lavenderColor]],];
    
    // create a layout box to group the color selectors together
    colorBox = [[CCLayoutBox alloc]init];
    colorBox.anchorPoint = ccp(0.5, 0.5);
    
    // from the plist, load the number of allowed colors
    numOfColors = [[levelProperties objectForKey:@"Colors"] intValue];
    
    // set properties of the dots and add them to the layout box
    for (int i = 0; i < numOfColors; i++){
        ColorSelector *c = [[ColorSelector alloc]initWithImageNamed:@"Images/ColorSelector.png"];
        c.color = possibleColors[(i+(userLevel-1)*numOfColors)%12];
        [c setScale: 1.0];
        c.visible = TRUE;
        c.used = FALSE;
        
        [colorBox addChild:c];
        [colors addObject:c];
    }
    
    // set properties of the layout box and draw them
    colorBox.direction = CCLayoutBoxDirectionHorizontal;
    colorBox.spacing = 25.f;
    [colorBox layout];
    
    [self addChild: colorBox];
    
    // make the color selector highlighter - basically tells which is current color being used
    ColorSelector *firstSelector = (ColorSelector*)colors[0];
    highlighter = [[CCSprite alloc]initWithImageNamed:@"Images/ColorSelectorHighlighter.png"];
    highlighter.color = [CCColor colorWithRed:.82 green: .859 blue: .741];
    highlighter.contentSize = CGSizeMake(firstSelector.contentSize.width, firstSelector.contentSize.height);
    highlighter.anchorPoint = ccp(0.575, 0.575);
    highlighter.position = firstSelector.positionInPoints;
    [firstSelector addChild: highlighter z: firstSelector.zOrder-1];
    
    // because drawing on Gameplay scene, which is the parent of everything else, need to use CCDirector to find middle of screen
    CCDirector *thisDirector = [CCDirector sharedDirector];
    colorBox.position = ccp([thisDirector viewSize].width/2.0, 50.0);
    
    // set the first color to the clearColor
    if (userLevel == 1){
        currentColor = [CCColor clearColor];
    }
    else {
        currentColor = ((ColorSelector*)colors[0]).color;
    }
    
#pragma mark buttons
    
    // initialize the back button
    [backButton setBackgroundColor:[CCColor colorWithUIColor: [UIColor ht_aquaColor]] forState:CCControlStateNormal];
    [backButton setBackgroundColor:[CCColor colorWithUIColor: [UIColor ht_mintColor]] forState:CCControlStateHighlighted];
    
    // initialize the back button
    [clearButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_aquaColor]] forState:CCControlStateNormal];
    [clearButton setBackgroundColor:[[CCColor alloc] initWithUIColor: [UIColor ht_mintColor]] forState:CCControlStateHighlighted];

#pragma mark making the level pretty
    
    // changing the background color
    ((CCNodeGradient *)self.children[0]).startColor = [CCColor colorWithRed:.369 green:.765 blue:1];
    ((CCNodeGradient *)self.children[0]).endColor = [CCColor colorWithRed: .369 green: .714 blue: 1];
    
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLoc = [touch locationInNode:_contentNode];
    
    if ([self withinLayoutBox:touchLoc]){
    
#pragma mark check which color was selected
        for (ColorSelector *c in colors)
        {
            // c is in node space of color Box
            double distanceToColor = [self distanceBetweenPoint:[colorBox convertToWorldSpace:c.positionInPoints] andPoint: touchLoc];
        
            // custom set, need to find a way to scale
            if(distanceToColor < c.contentSize.width/2){
                currentColor = c.color;
                id moveAction = [CCActionMoveTo actionWithDuration:.5 position:c.positionInPoints];
            
                [highlighter runAction:[CCActionSequence actions:moveAction,nil]];
                
#pragma mark tutorial stuff
                if (userLevel == 1){
                    if ([self checkColorEquality:currentColor and:[CCColor colorWithUIColor: [UIColor ht_alizarinColor]]] && numVerticesColored == 0){
                    tutorialText.visible = FALSE;
                        [tutorialText setString: @"Place it here!"];
                    
                    
                        tutorialText.position = ccp(((Vertex*)_listOfVertices[0]).positionInPoints.x + 77.5, ((Vertex*)_listOfVertices[0]).positionInPoints.y - 25);
                        tutorialText.visible = TRUE;
                    
                        // pulse the correct vertex
                        ((Vertex*)_listOfVertices[0]).isFlashing = TRUE;
                        [((Vertex*)_listOfVertices[0]) pulse];

                    }
                    else if ([self checkColorEquality:currentColor and:[CCColor colorWithUIColor: [UIColor ht_carrotColor]]] && numVerticesColored == 1){
                    
                        tutorialText.visible = FALSE;
                        [tutorialText setString: @"Place it here!"];
                    
                    
                        tutorialText.position = ccp(((Vertex*)_listOfVertices[1]).positionInPoints.x - 77.5, ((Vertex*)_listOfVertices[0]).positionInPoints.y - 25);
                        tutorialText.visible = TRUE;
                    
                        // blink the proper vertex
                        ((Vertex*)_listOfVertices[1]).isFlashing = TRUE;
                        [((Vertex*)_listOfVertices[1]) pulse];
                        
                    }
                    else if(numVerticesColored == 2){
                        tutorialText.visible = FALSE;
                    }
                }
                
                break;
            }
        }
    }
    
    else if (![self checkColorEquality:currentColor and: [CCColor clearColor]]){

#pragma mark check which vertex was touched
        for (Vertex *v in _listOfVertices)
        {
            double distanceToVertex = [self distanceBetweenPoint:[_contentNode convertToWorldSpace:v.position] andPoint:touchLoc];
        
            if (distanceToVertex < v.contentSize.height){
            
                // if current color is not equal to the vertex color (prevent extraneous dots being created)
                if (![self checkColorEquality:currentColor and: v.color]) {
                    
                    // if number of colored vertices is less than total number of vertices and that has not been previously colored and currently selected a color
                    if (numVerticesColored < numOfVertices && [self checkColorEquality:v.color and:[CCColor blackColor]])
                    {
                        numVerticesColored++;
                    }
                
                 
                    // drawing the dot and setting the invisible vertex color
                    v.color = currentColor;
                    
#pragma mark tutorial
                    if (userLevel == 1){
                        if (v.tag != ((Vertex*)(_listOfVertices[0])).tag && numVerticesColored == 1){
                            v.color = [CCColor blackColor];
                            numVerticesColored--;
                        }
                        else if (v.tag != ((Vertex*)(_listOfVertices[1])).tag && numVerticesColored == 2){
                            v.color = [CCColor blackColor];
                            numVerticesColored--;
                        }
                        else if (v.tag == ((Vertex*)(_listOfVertices[0])).tag && numVerticesColored == 1){
                            tutorialText.visible = FALSE;
                            [tutorialText setString: [NSString stringWithFormat:@"%@\r%@\r%@", @"Now that this dot is red",@"The two dots connected to it", @"can't be red!"]];
                            tutorialText.anchorPoint = ccp(0.5, 0.5);
                            tutorialText.position = ccp([[CCDirector sharedDirector]viewSize].width/2, [[CCDirector sharedDirector]viewSize].height/2);
                            tutorialText.horizontalAlignment = CCTextAlignmentCenter;
                            tutorialText.visible = TRUE;
                            
                            // blink the vertices that tutorial is referring to
                            id firstBlinkAction = [CCActionBlink actionWithDuration:5 blinks:5];
                            id secondBlinkAction = [CCActionBlink actionWithDuration:5 blinks:5];
                            [(Vertex*)_listOfVertices[1] runAction:[CCActionSequence actions:firstBlinkAction,nil]];
                            [(Vertex*)_listOfVertices[2] runAction:[CCActionSequence actions:secondBlinkAction,nil]];
                            
                            self.userInteractionEnabled = FALSE;
                            [NSTimer
                             scheduledTimerWithTimeInterval:(NSTimeInterval)(5)
                             target:self
                             selector:@selector(presentChooseOrangeText: )
                             userInfo:nil
                             repeats:false];

                        }
                        else if (numVerticesColored == 2){
                            tutorialText.visible = FALSE;
                            [tutorialText setString:@"Now you finish the puzzle!"];
                            tutorialText.anchorPoint = ccp(0.5, 0.5);
                            tutorialText.position = ccp([[CCDirector sharedDirector]viewSize].width/2, [[CCDirector sharedDirector]viewSize].height/2);
                            tutorialText.horizontalAlignment = CCTextAlignmentCenter;
                            tutorialText.visible = TRUE;
                        }
                    }
                    
#pragma mark flashes screen
                   flashView = [[CCNodeColor alloc]initWithColor: [currentColor colorWithAlphaComponent:0.25f] width:[[CCDirector sharedDirector]viewSize].width height: [[CCDirector sharedDirector]viewSize].height];
                    flashView.position = ccp(0,0);
                    [self addChild:flashView];
                                      [NSTimer
                                      scheduledTimerWithTimeInterval:(NSTimeInterval)(0.25)
                                      target:self
                                      selector:@selector(removeColorFlash)
                                      userInfo:nil
                                      repeats:false];
                
                    // only run bfs check when touching a vertex, so not in touchEnded
                    if (numVerticesColored == numOfVertices)
                    {
                        [self submit];
                    }
                    else if (userLevel == 1 && numVerticesColored > 2)
                    {
                        [self tutorialCheck:v];
                    }
                    break;
                }
            }
        }
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

#pragma mark methods for buttons

- (void)clear {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

-(void)submit{
    Boolean isValidColoring = [self bfs: [_listOfVertices lastObject]];
    
    // load in the path of NSUserDefaults
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Level Properties" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (isValidColoring){
        
        // go to the next level
        userLevel++;
        
        // if user still has levels to complete
        if (userLevel <= [levels count]){
            [[NSUserDefaults standardUserDefaults] setObject:[[NSNumber alloc]initWithInt:userLevel] forKey:@"userLevel"];
            CCScene *mainScene = [CCBReader loadAsScene:@"SuccessScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]];
        }
        
        // else load the end scene
        else{
            CCScene *mainScene = [CCBReader loadAsScene:@"EndScene"];
            [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1]];
        }
    }
}

- (void)back {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene withTransition: [CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1]];
}

#pragma mark helper functions

// distance formula for use in drawing lines
-(double)distanceBetweenPoint: (CGPoint) point1 andPoint: (CGPoint) point2
{
    double dx = (point2.x-point1.x);
    double dy = (point2.y-point1.y);
    double dist = dx*dx + dy*dy;
    return sqrt(dist);
}

-(Boolean)withinLayoutBox: (CGPoint)touch{
    float minX = colorBox.position.x - colorBox.contentSize.width/2;
    float maxX = colorBox.position.x + colorBox.contentSize.width/2;
    float minY = colorBox.position.y - colorBox.contentSize.height/2;
    float maxY = colorBox.position.y + colorBox.contentSize.height/2;
    return (touch.x >= minX && touch.x <= maxX && touch.y >= minY && touch.y <= maxY);
}

// colors are equal only when RGBA of both colors are equal
- (Boolean)checkColorEquality : (CCColor*)colorOne and: (CCColor*)colorTwo{
    if (colorOne.red != colorTwo.red){
        return false;
    }
    if (colorOne.green != colorTwo.green){
        return false;
    }
    if(colorOne.blue != colorTwo.blue){
        return false;
    }
    return true;
}


// running BFS on the graph to check all permutations of vertex color equality
- (Boolean)bfs: (Vertex*)startingVertex{
    
    // list of the visited nodes
    NSMutableSet *visitedNodes = [NSMutableSet setWithObject:startingVertex];
    
    // the queue from which we pop off the next vertex to visit
    NSMutableArray *queue = [NSMutableArray arrayWithObject:startingVertex];
    
    // the color we need to see if anything else is equal to
    CCColor *colorToCheckAgainst;
    
    // run bfs while still have vertices to relax
    while ([queue count] > 0)
    {
        // get all the adjacent vertices of current vertex
        NSSet *newNodes = ((Vertex *)[queue objectAtIndex:0]).linkedNodes;
        
        // set the color to check against to the current vertex's color
        colorToCheckAgainst = ((Vertex *)[queue objectAtIndex:0]).color;
        
        // relax and check all nodes
        for (Vertex *newNode in newNodes)
        {
            // if two adjacent nodes equal in color, return false
            if ([self checkColorEquality:newNode.color and:colorToCheckAgainst]){
                return FALSE;
            }
            
            // if a new node that we haven't relaxed, add to the queu and visitedNodes
            if (![visitedNodes containsObject:newNode])
            {
                [visitedNodes addObject:newNode];
                [queue addObject:newNode];
            }
        }
        
        // check the next vertex
        [queue removeObjectAtIndex:0];
    }
    
    // all vertices have been checked and therefore must be true
    return TRUE;
}

-(void)tutorialCheck: (Vertex*)v{
    CCColor *colorToCheckAgainst = v.color;
    NSSet *currentNodeNeighbors = v.linkedNodes;
    for (Vertex* neighbors in currentNodeNeighbors){
        if ([self checkColorEquality:colorToCheckAgainst and:neighbors.color]){
            tutorialText.visible = FALSE;
            [tutorialText setString:[NSString stringWithFormat:@"%@\r%@\r%@", @"Remember!",@"Connected dots cannot be", @"The same color!"]];
            tutorialText.anchorPoint = ccp(0.5, 0.5);
            tutorialText.position = ccp([[CCDirector sharedDirector]viewSize].width/2, [[CCDirector sharedDirector]viewSize].height/2);
            tutorialText.horizontalAlignment = CCTextAlignmentCenter;
            tutorialText.visible = TRUE;
            [NSTimer
             scheduledTimerWithTimeInterval:(NSTimeInterval)(2)
             target:self
             selector:@selector(textInvisible: )
             userInfo:nil
             repeats:false];
            
        }
    }
    
}

#pragma mark tutorial

-(void)presentWelcome{
    
    tutorialText = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"Start by choosing the red dot!"] fontName: @"HelveticaNeue-Light" fontSize:25];
    [tutorialText setPosition: ccp(colorBox.position.x, colorBox.position.y-30)];
    [self addChild:tutorialText];
}

-(void)presentChooseOrangeText: (NSTimer*)timer{
    tutorialText.visible = FALSE;
    [tutorialText setPosition: ccp(colorBox.position.x, colorBox.position.y-30)];
    [tutorialText setString:@"So, let's choose orange!"];
    tutorialText.visible = TRUE;
    self.userInteractionEnabled = TRUE;
}

-(void)textInvisible: (NSTimer*)timer{
    tutorialText.visible = FALSE;
}

-(void)removeColorFlash{
    [self removeChild:flashView];
}

@end
//
//  GameViewLayer.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <CoreFoundation/CoreFoundation.h>
#import "GameLayer.h"
@class World;
@interface GameViewLayer : GameLayer
@property (nonatomic, assign) World* m_world;

@end

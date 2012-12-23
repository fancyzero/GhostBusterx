//
//  GameViewLayer.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameViewLayer.h"
#import "GameBase.h"

@implementation GameViewLayer 
@synthesize m_world;


-(void) update: (ccTime) delta_time
{

    [[ GameBase get_game] update:delta_time];
    [[ GameBase get_game ].m_level update:delta_time];
    [ m_world update: delta_time];


     return;
}
@end

//
//  GameObjBase.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameObjBase.h"

@implementation GameObjBase
@synthesize  m_name;
@synthesize m_tag;

-(int) init_default_values
{
	trigger_id_ = -1;
	return 0;
}

-(id) init_with_spawn_params:(NSDictionary*) params
{
	return self;
}
-(void) update: (float)delta_time
{
    
}

-(void) cleanup
{

}
- (void)dealloc
{
    NSLog(@"%@ dealloc" , self);
    [super dealloc];
}

-(void) set_trigger_id:(int) trigger_id
{
	//NSLog(@"Spawn class:%@ with triggerid: %d", self, trigger_id);
	trigger_id_ = trigger_id;
}

-(int) get_trigger_id
{
	return trigger_id_;
}
@end

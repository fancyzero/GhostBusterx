//
//  LevelCollider.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-22.
//
//

#import "LevelCollider.h"
#import "GBLevel.h"
#import "PhysicsSprite.h"
@implementation LevelCollider


-(void) init_by_level:(GBLevel*)level
{
	PhysicsSprite* spr = [PhysicsSprite new ];
	spr.m_parent = self;
	spr.m_position = ccp(0,0) ;
	spr.m_rotation = 0;
	[level setup_level_collider:spr];

	m_sprite_components.push_back(spr);
		//[m_root_node_ addChild:spr];
	[self set_collision_filter:0xffffffff cat:4];
}
@end

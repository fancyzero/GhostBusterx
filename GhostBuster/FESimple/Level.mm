//
//  Level.m
//  dodgeandrun
//
//  Created by Fancy Zero on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#include <vector>
#import "World.h"
#import "SpriteXMLParser.h"
#import "PhysicsDebuger.h"
#import "GameScene.h"
#include <box2d.h>
#import "Common.h"
#import "GameBase.h"


@interface LevelParser : SPriteParserBase
{
@public
	LevelBase*			m_level;
	float				m_current_progress_parsed;
	int					m_current_id;
}
-(void) on_node_begin:(NSString*) cur_path  nodename:(NSString *)node_name attributes:(NSDictionary *)attributes;
-(void) on_node_end:(NSString*) cur_path  nodename:(NSString* ) node_name;
@end

@implementation LevelParser

-(id) init
{
	self = [super init];
	m_current_id = 0;
	return self;
}
-(void) on_node_begin:(NSString *)cur_path nodename:(NSString *)node_name attributes:(NSDictionary *)attributes
{
    if ( [ cur_path isEqualToString:@"/xml" ] )
    {
        if ( [ node_name isEqualToString:@"level" ] )
        {
			[ m_level set_map_size:[[ attributes valueForKey:@"map_width" ] intValue ]:[[ attributes valueForKey:@"map_height" ] intValue]];
		}
    }
    if ( [ cur_path isEqualToString:@"/xml/level/acting_range" ] )
    {
        if ( [ node_name isEqualToString:@"keyframe" ] )
        {
			level_acting_range_keyframe k;
			CGPoint p;
			p = read_CGPoint_value(attributes, @"pos", ccp(0, 0));
			k.act_rect.origin = p;
			p = read_CGPoint_value(attributes, @"size", ccp(0, 0));
			k.act_rect.size.width = p.x;
			k.act_rect.size.height = p.y;
			k.progress = read_float_value(attributes, @"progress");
			[m_level add_acting_range_keyframe: k];
		}
    }
	if ( [ cur_path isEqualToString:@"/xml/level/actions"])
	{
		if ( [ node_name isEqualToString:@"action" ] )
		{
			level_progress_trigger trigger;
			trigger.id = m_current_id;
			m_current_id++;
			trigger.action_type = -1;
			trigger.progress_pos = [[attributes valueForKey:@"progress"] floatValue] + m_current_progress_parsed;
			m_current_progress_parsed = trigger.progress_pos;
			NSString* act = [attributes valueForKey:@"act"];
			if ( [act isEqualToString:@"add_obj"] )
			{
				trigger.action_type = ta_addobj;
			}
			if ( [act isEqualToString:@"rand_add_obj"] )
			{
				trigger.action_type = ta_rand_addobj;
			}
			trigger.script = [attributes valueForKey:@"class"];
			[trigger.script retain];
			//todo: memory leak
			trigger.params = [NSMutableDictionary dictionaryWithDictionary:attributes];
			[trigger.params retain];
			[m_level add_trigger: trigger];
			
			
		}
		//trigger.
	}
}


-(void) on_node_end:(NSString *)cur_path nodename:(NSString *)node_name
{
    
}
@end

@implementation LevelBase

@synthesize m_acting_range = m_acting_range_;
@synthesize m_map_rect = m_map_rect_;
@synthesize m_need_reset;
@synthesize m_level_progress = m_level_progress_;
@synthesize m_current_trigger;
@synthesize m_acting_range_velocity = m_acting_range_velocity_;


-(id) init
{
	m_current_trigger = 0;
    m_need_reset = false;
	m_acting_range_body_ = NULL;
    return self;
}

-(void) add_acting_range_keyframe:(const level_acting_range_keyframe &)key
{
	m_acting_range_keyframes_.push_back(key);
}

-(void)	add_trigger: (level_progress_trigger) trigger
{
	m_level_triggers.push_back(trigger);
}

-(int) load_from_file:(NSString*) filename
{
	m_filename_ = filename;
    NSURL *xmlURL = [NSURL fileURLWithPath:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:filename]];
    NSXMLParser* xmlparser = [[ NSXMLParser alloc ] initWithContentsOfURL:xmlURL];
	SpriteXMLParser *sxmlparser = [[ SpriteXMLParser alloc] init:NULL];
    LevelParser* my_parser = [ LevelParser new];
	my_parser->m_level = self;
	[ sxmlparser->m_parsers addObject: my_parser ];
	[ xmlparser setDelegate:sxmlparser];
	BOOL ret = [ xmlparser parse ];
	assert( ret );
	ret = 0;
	
	[sxmlparser release];
	[xmlparser release];
	return 0;
}

-(void) updaet_acting_range_physic
{
	float ptm = [GameBase get_ptm_ratio];

	b2BodyDef bodydef;
	bodydef.type = b2_staticBody;
	bodydef.position = b2Vec2(0,0);
	b2Body* body = [GameBase get_game].m_world.m_physics_world->CreateBody(&bodydef);
	
	b2EdgeShape edge;
	float x1, y1,x2,y2;
	x1 = m_acting_range_.origin.x/ptm;
	y1 = m_acting_range_.origin.y/ptm;
	x2 = (m_acting_range_.origin.x + m_acting_range_.size.width) / ptm;
	y2 = (m_acting_range_.origin.y + m_acting_range_.size.height) / ptm;
	edge.Set(b2Vec2(x1,y1),b2Vec2(x2,y1));
	b2Filter filter;
	filter.categoryBits=cg_acting_range;
	filter.maskBits=cg_player1 | cg_player2 | cg_acting_range;

	body->CreateFixture(&edge,1)->SetFilterData(filter);
	edge.Set(b2Vec2(x2,y1),b2Vec2(x2,y2));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	edge.Set(b2Vec2(x2,y2),b2Vec2(x1,y2));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	edge.Set(b2Vec2(x1,y2),b2Vec2(x1,y1));
	body->CreateFixture(&edge,1)->SetFilterData(filter);;
	
	if ( m_acting_range_body_ != NULL )
		[GameBase get_game].m_world.m_physics_world->DestroyBody(m_acting_range_body_);
	m_acting_range_body_  = body;

}

-(void) set_acting_range : (CGRect)rect
{
	m_acting_range_ = rect;
	//NSLog(@"set act range: %f, %f", rect.size.width, rect.size.height);
	[self updaet_acting_range_physic];
}

-(void) on_sprite_dead: (SpriteBase*) sprite{}
-(void) on_remove_obj: (GameObjBase*) obj{}
-(void) on_sprite_spawned: (SpriteBase*) sprite{}
-(void) on_add_obj: (GameObjBase*) obj{}
-(void) on_level_start{}
-(void) reset
{
	if ( m_acting_range_body_ != NULL )
	{
		[GameBase get_game].m_world.m_physics_world->DestroyBody(m_acting_range_body_);
		m_acting_range_body_ = NULL;
	}
	m_level_triggers.clear();
	m_current_trigger = 0;
	m_level_progress_ = 0;
	if ( m_filename_ != nil)
		[self load_from_file:m_filename_];

};
-(void) request_reset
{
    m_need_reset = true;
}
-(void) update:(float)delta_time
{
    if ( m_need_reset )
    {
        [ self reset];
        m_need_reset = false;
    }
	m_level_progress_ += delta_time;
};
-(void) set_map_size:(int)w :(int)h
{
    m_map_rect_.origin.x = 0;
    m_map_rect_.origin.y = 0;
    m_map_rect_.size.width = w;
    m_map_rect_.size.height = h;
}
-(level_progress_trigger*) get_trigger_by_id:(int) tid
{
	std::vector<level_progress_trigger>::iterator it;
	for ( it = m_level_triggers.begin(); it != m_level_triggers.end(); ++it )
	{
		if ( (*it).id == tid )
			return &(*it);
	}
	return NULL;
}

@end


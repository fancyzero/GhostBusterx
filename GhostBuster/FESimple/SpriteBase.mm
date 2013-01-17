//
//  SpriteBase.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#include "Box2D.h"
#import "SpriteBase.h"
#import "CCSprite.h"

#import "Common.h"
#import "Simpleaudioengine.h"
#include <vector>
#import "SpriteDefManager.h"
#import "Level.h"
#import "World.h"
#import "Custom_Interfaces.h"
#import "CollisionListener.h"
#import "GameLayer.h"
#import "SpriteProxy.h"
#import "GameBase.h"

@implementation SpriteBase 

@synthesize m_position;
@synthesize m_zorder;
@synthesize m_rotation;
@synthesize m_scale;
@synthesize m_color;
@synthesize m_health;
@synthesize m_spawned_time;
@synthesize m_time_before_remove_outof_actrange = m_time_before_remove_outof_actrange_;
@synthesize m_max_health =m_max_health_;

-(CGPoint) m_position
{
	if ( m_sprite_components.size()>0 )
		return m_sprite_components[0].m_position;
	else
		return ccp(0,0);
}
//@synthesize m_root_node = m_root_node_;
-(int) init_default_values
{
	[super init_default_values];
    m_spawned_time = [GameBase current_time];
	if ( [ GameBase get_game ].m_level != NULL )
		m_spawned_progress_ = [ GameBase get_game ].m_level.m_level_progress;
	else
		m_spawned_progress_ = 0;

    m_dead = false;
    m_scale = 1.0f;
	m_dead_on_health_empty = true;
	m_scalex = 1;
	m_scaley = 1;
	m_removed = false;
	m_time_before_remove_outof_actrange_ = 10;
	m_been_in_range_ = false;
	m_time_outof_actrange_ = 0;
	m_blink_end_time_ = 0;
	m_visible_set_ = 0;
    m_hitproxy_ = NULL;
	//m_root_node_ = [CCNode node];

	return 0;
}
-(id) init
{
    self = [ super init ];
	[ self init_default_values];
    return self;
}


-(id) init_with_spawn_params:(NSDictionary*) params
{
	
	self = [super init_with_spawn_params:params];//self init_default_values 必须在self 被附直后才能使用
	[ self init_default_values];
	[self read_sprite_spawn_param:params];
	CGPoint init_pos;
	if ( !m_spawn_param.init_pos_rel_act )
		init_pos = m_spawn_param.init_position;
	else
	{
		init_pos = current_acting_range().origin;
		init_pos = ccpAdd(init_pos, m_spawn_param.init_position);
		
	}
	[self set_position:init_pos.x y:init_pos.y];
	[self set_rotation:m_spawn_param.init_rotation];
	[self set_scale:m_spawn_param.init_scale :m_spawn_param.init_scale];
	[self set_rotation:m_spawn_param.init_rotation];
	[self init_with_xml:m_spawn_param.sprite_desc];

	[ self set_zorder:m_spawn_param.init_zorder];


//	[self read_sprite_spawn_param: params ];
    return self;
}

-(void) dead
{
    if ( m_dead == true )
        return;
    m_dead = true;
    
    LevelBase* lvl;
    lvl = [GameBase get_game].m_level;
    if ( lvl != NULL )
    {
        [lvl on_sprite_dead:self];
    }
}
-(bool) isdead
{
    return m_dead;
}

-(void) cleanup
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		if ( (*it) )
			[ *it release];
	}
	m_sprite_components.clear();
	
	for ( DROPDESCS::iterator it = m_drop_descs.begin(); it != m_drop_descs.end(); ++it )
	{
		if ( (*it).params != NULL )
			[(*it).params release];
		if ( (*it).spriteclass != NULL )
			[(*it).spriteclass release];
		
	}
	m_drop_descs.clear();
    [m_hitproxy_ release];
    m_hitproxy_ = NULL;
	//[m_root_node_ release];
	//m_root_node_ = NULL;
    //GameSad* game = [ GameBase get_game ];
    //NSLog( @"%@ : m_physics_body = %p", self, m_physics_body);
}
//int j = 0;
-(void) dealloc
{
    GameBase* game = [ GameBase get_game ];
    //if ( game.m_DBG_loop_stat <= 1 )
    //{
    //    j++;
    //}
    assert( game.m_DBG_loop_stat > 1 );
    //NSLog( @"%@ : %@ destroyed.", self, self.m_name );
    [ self cleanup];
    [super dealloc];

}
-(int) collied_with:(SpriteBase *)other :(Collision*) collision
{
    //NSLog( @"%@ collied with %@", self.m_name, other.m_name );
    return 0;
}


-(void) set_position: (float)x y:(float)y
{
    m_position.x = x;
    m_position.y = y;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		CGPoint pos = m_position;

		if ( (*it) )
		{
			pos.x += (*it).m_offset.x;
			pos.y += (*it).m_offset.y;
			(*it).m_position = pos;
		}
	}
	//[m_root_node_ setPosition:m_position];
}

-(void) set_rotation:(float)rotat
{
	m_rotation = rotat;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) setRotation:rotat];
		}
	}
	//[m_root_node_ setRotation:-rotat];
}

-(void) set_scale:(float)scalex:(float) scaley
{
	m_scalex = scalex;
	m_scaley = scaley;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) set_scale:scalex :scaley];
		}
	}
}

-(void) set_zorder: (int)z
{
    m_zorder = z;
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it)
		{
			[(*it) setZOrder:z];
		}
	}
}

-(int) post_init
{
	return 0;
}

-(void) add_drop_desc:(drop_desc) desc
{
	[desc.params retain];
	[desc.spriteclass retain];
	m_drop_descs.push_back(desc);
}

-(int) init_with_xml:(NSString *)filename
{
	float ptm = [GameBase get_ptm_ratio];
    sprite_def* sdef = [ SpriteDefManager load_sprite_def:filename];
	
	for ( SPRITEPARTDEFS::iterator it = sdef->m_parts.begin(); it != sdef->m_parts.end(); ++it )
	{
		PhysicsSprite* spr = [PhysicsSprite new ];
		spr.m_parent = self;
		spr.m_position = m_position ;
		spr.m_rotation = m_rotation;
		if ( m_scalex <= 0 )
			m_scalex = 1;
		spr.scaleX = m_scalex;
		spr.scaleY = m_scaley;

		spr.m_position = ccpAdd( spr.m_position, (*it).m_offset );
		sprite_component_def* scdef = [ SpriteDefManager load_sprite_component_def:(*it).m_desc];


		[ spr init_by_sprite_component_def: scdef ];
		//spr.m_position = (*it).m_offset;

		m_sprite_components.push_back(spr);
		//[m_root_node_ addChild:spr];
	}
	for ( SPRITEJOINTDEFS::iterator it = sdef->m_joints.begin(); it != sdef->m_joints.end(); ++it )
	{
		if ( (*it).joint_type == e_revoluteJoint )
		{
			b2RevoluteJointDef joint;
			PhysicsJoint pj;
			int idxa = (*it).component_a;
			int idxb = (*it).component_b;
			
			joint.Initialize(m_sprite_components[idxa].m_phy_body, m_sprite_components[idxb].m_phy_body, b2Vec2(m_sprite_components[idxb].m_position.x/ptm, m_sprite_components[idxb].m_position.y/ptm));
			joint.enableLimit = (*it).joint_flags[0];
			joint.upperAngle = CC_DEGREES_TO_RADIANS( (*it).joint_params[0] );
			joint.lowerAngle = CC_DEGREES_TO_RADIANS( (*it).joint_params[1] );
			pj.m_b2Joint =	[GameBase get_game].m_world.m_physics_world->CreateJoint(&joint);
			
			m_physic_joints.push_back(pj);
		}
	}
	[self post_init];
    return 1;
}

-(void) blink:(float)duration
{
	m_blink_end_time_ = current_game_time() + duration;
}

-(void) play_anim_sequence:(NSString *)name
{
}

-(void) set_collision_filter:(int)mask  cat:(int) cat
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		
		if (*it != NULL )
		{
			[(*it) set_collision_filter:mask cat:cat];
		}
	}
}



-(void) setM_color:(ccColor4B)color
{
    ccColor3B tmpc;
    tmpc.r = color.r;
    tmpc.g = color.g;
    tmpc.b = color.b;
	//todo

}

-(ccColor4B) m_color
{
    ccColor4B tempc;
	//todo
    return tempc;
}

-(void) set_color_override :( ccColor4F ) color mask:(float) mask  duration:(float) duration
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		[ (*it) set_color_override :color mask:mask duration:duration];
	}
}

-(void) init_shader
{

}

-(void) sync_physic_to_sprite
{
	for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
	{
		[(*it) sync_physic_to_sprite];
	}
}

-(void) set_visible:(bool) visible :(unsigned int) flag
{
	unsigned int old_vis_set = m_visible_set_;
	if ( !visible )
		m_visible_set_ |= flag;
	else
		m_visible_set_ &= ~flag;
	
	if ( old_vis_set != m_visible_set_)
	{
		
		if( m_visible_set_ != 0)
		{
			for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
			{
				[(*it) setVisible:false];
			}
		}
		else
		{
			for ( SPRITECOMPONENTS::iterator it = m_sprite_components.begin(); it != m_sprite_components.end(); ++it )
			{
				[(*it) setVisible:true];
			}
		}
	}
}

-(void) update : (float)delta_time
{
	[ self sync_physic_to_sprite];
	if ( m_time_before_remove_outof_actrange_ > 0 && ![[GameBase get_game] is_editor])
	{
		if ( m_time_before_remove_outof_actrange_ > 0 && m_been_in_range_ &&  m_time_outof_actrange_ > m_time_before_remove_outof_actrange_ )
		{
			[self remove_from_game:true];
		}
		float rad = m_sprite_components[0].boundingBox.size.width;
		if ( rad < m_sprite_components[0].boundingBox.size.height)
			rad = m_sprite_components[0].boundingBox.size.height;
		CGRect rc = m_sprite_components[0].layer_bounding_box;

		bool outofrange = is_outof_acting_range(self.m_position, rc, [m_sprite_components[0] get_layer].m_move_scale  );
		if ( outofrange && m_been_in_range_ )
			m_time_outof_actrange_ += delta_time;
		if ( !outofrange )
			m_been_in_range_ = true;
	}
	if ( m_blink_end_time_ > current_game_time())
	{
		float d = (m_blink_end_time_ - current_game_time());
		if ( sinf(d*3.14*10) < 0 )
			[ self set_visible:false :2];
		else
			[ self set_visible:true :2];
	}
	else
	{
		[ self set_visible:true :2];
	}
}

//logic
-(void) apply_damage:(float) dmg collision:(struct Collision*) collision
{
	float last_health = m_health;
    m_health -= dmg;
    if ( last_health > 0 && m_health <= 0)
        [ self on_health_empty];
    else
    {
        SimpleAudioEngine* eng = [SimpleAudioEngine sharedEngine];
        [ eng playEffect:@"sfx/hit1.wav"];
		
		PhysicsSprite* sprite_comp_A = (PhysicsSprite*)collision->fixtureA->GetUserData();
		PhysicsSprite* sprite_comp_B = (PhysicsSprite*)collision->fixtureB->GetUserData();

		if ( sprite_comp_A.m_parent == self )
			[ sprite_comp_A set_color_override:ccc4f(1,1,1,1) mask:0.5 duration:0.1];
		if ( sprite_comp_B.m_parent == self )
			[ sprite_comp_B set_color_override:ccc4f(1,1,1,1) mask:0.5 duration:0.1];
    }
 
}

-(void) random_drop
{
	if ( m_drop_descs.size() > 0 )
	{
		int idx = rand()% m_drop_descs.size();
		drop_desc desc = m_drop_descs[idx];
		NSString* clsname = NULL;
		NSMutableDictionary* params = NULL;

		clsname = desc.spriteclass;
		params = [NSMutableDictionary dictionaryWithDictionary:desc.params ];
		
		SpriteBase* spr = (SpriteBase*)[[GameBase get_game] add_game_obj_by_classname:clsname spawn_params:params];
		[spr set_position:self.m_position.x y:self.m_position.y];
		//[params release];
	}
}

- (void) on_health_empty
{
	[self random_drop ];
}

-(void) remove_from_game:(bool) dead
{
	//assert(!m_removed);
    if ( dead )
        [self dead];
	if ( !m_removed )
	{
		m_removed=true;
		
		GameBase* game = [GameBase get_game];
		[ game.m_world remove_gameobj:self];
		[ self release ];
	}

}


-(void) read_sprite_spawn_param:(NSDictionary*) params
{
	::load_sprite_spawn_param( &m_spawn_param, params );
}

-(PhysicsSprite*)	m_first_sprite
{
	if ( m_sprite_components.size() > 0 )
		return m_sprite_components[0];
	else
		return NULL;
}

-(int) sprite_components_count
{
	return m_sprite_components.size();
}
-(PhysicsSprite*) get_sprite_component: (int) index
{
	if ( m_sprite_components.size() > index )
	{
		return m_sprite_components[index];
	}
	else
		return NULL;
}


-(void) set_physic_position:(int) component :(CGPoint) pos
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_position: pos];
}
-(void) set_physic_angular_velocity:(int) component :(float) v
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_angular_velocity: v];
}
-(void) set_physic_mass:(int) component :(float) v
{
	if ( m_sprite_components.size() > component )
	{
		b2MassData md;
		m_sprite_components[component].m_phy_body->GetMassData(&md);
		md.mass = v;
		
		m_sprite_components[component].m_phy_body->SetMassData(&md);
	}
	
}
-(void) set_physic_angular_damping:(int) component :(float) d
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_angular_damping: d];
}
-(void) set_physic_linear_damping :(int) component :(float) damping
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_linear_damping: damping];
}
-(float) get_physic_rotation:(int) component
{
	if ( m_sprite_components.size() > component )
		return [ m_sprite_components[component] get_physic_rotation ];
	else
		return 0;
}
-(void) set_physic_rotation:(int) component :(float) angle
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_rotation: angle];
}
-(void) set_physic_linear_velocity:(int) component : (float) x :(float) y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_linear_velocity:x :y];
}
-(void) set_physic_fixed_rotation:(int) component : (bool) fixed
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] set_physic_fixed_rotation:fixed];
}

-(void) apply_linear_impulse:(int) component :(float)speed_x speed_y:(float)speed_y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component] apply_linear_impulse:speed_x speed_y:speed_y ];
}
-(void) apply_force_center:(int) component :(float)force_x force_y:(float)force_y
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component]  apply_force_center:force_x force_y:force_y];
}
-(float) get_physic_angular_velocity:(int) component
{
	if ( m_sprite_components.size() > component )
		return [m_sprite_components[component] get_physic_angular_velocity];
	else
		return 0;
}
-(CGPoint) get_physic_linear_velocity:(int) component
{

	if ( m_sprite_components.size() > component )
		return [m_sprite_components[component] get_physic_linear_velocity];
	else
	{
		CGPoint ret;
		ret.x = ret.y = 0;
		return ret;
	}
}

-(void) clamp_physic_maxspeed:(int) component :(float) max_speed
{
	if ( m_sprite_components.size() > component )
		[m_sprite_components[component]  clamp_physic_maxspeed:max_speed];
}

-(void) heal:(float)health
{
	m_health += health;
	if ( m_health > m_max_health_ )
		m_health = m_max_health_;
}
//editor interface

-(void) set_selected :(bool) selected
{
	
}

-(SpriteHitProxy*) get_hitproxy
{
    if ( m_hitproxy_ == NULL )
    {
        m_hitproxy_ = [SpriteHitProxy new];
        [m_hitproxy_ set_sprite:self];
    }
	return m_hitproxy_;
}

-(void) set_layer:(GameLayer*) layer
{
	m_layer_ = layer;
}
-(GameLayer*) get_layer
{
	return m_layer_;
}

@end

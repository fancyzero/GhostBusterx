//
//  SpriteBase.h
//  testproj1
//
//  Created by Fancy Zero on 12-3-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <vector>
#import "GameObjBase.h"
#import "CCSprite.h"
#import "PhysicsSprite.h"
#import "Custom_Interfaces.h"

@class SpriteBase;
@class GameLayer;
struct drop_desc 
{
	NSString* spriteclass;
	NSDictionary* params;
};

class PhysicsJoint
{
public:
	struct b2Joint*	m_b2Joint;
};

struct phy_body_userdata
{
	SpriteBase*	sprite;
	NSString*	identity;
};

typedef std::vector<PhysicsSprite*> SPRITECOMPONENTS;
typedef std::vector<PhysicsJoint>	PHYSICJOINTS;
typedef std::vector<drop_desc>		DROPDESCS;
@class SpriteHitProxy;
@interface SpriteBase : GameObjBase
{
@public
	struct sprite_spawn_param	m_spawn_param;
@protected
    bool                        m_dead;
	bool						m_dead_on_health_empty;
	SPRITECOMPONENTS			m_sprite_components;
	PHYSICJOINTS				m_physic_joints;
	DROPDESCS					m_drop_descs;
	float						m_scalex;
	float						m_scaley;
	float						m_activate_progress_range;
	bool						m_removed;	//removed frome game, for debug
	float						m_spawned_progress_;
	float						m_max_health_;
	float						m_time_outof_actrange_;
	float						m_time_before_remove_outof_actrange_;
	bool						m_been_in_range_;//is this sprite shown in the range before
	float						m_blink_end_time_;
	unsigned int				m_visible_set_;
	SpriteHitProxy*				m_hitproxy_;
	GameLayer*					m_layer_;
	//CCNode*						m_root_node_;
	
}
@property (nonatomic, assign) int m_zorder;
@property (nonatomic, assign) float m_max_health;
@property (nonatomic, assign, readonly) float      m_rotation;
@property (nonatomic, assign, readonly) CGPoint    m_position;
@property (nonatomic, assign, readonly) float      m_scale;
@property (nonatomic, assign, readonly) PhysicsSprite*	m_first_sprite;
@property (nonatomic, assign) ccColor4B  m_color;
@property (nonatomic, assign) float m_time_before_remove_outof_actrange;
//@property (nonatomic, assign) CCNode*	m_root_node;


//logic
@property (nonatomic, assign) float        m_health;


-(int) init_default_values;
-(int) post_init;
-(void) set_color_override :( ccColor4F ) color mask:(float) mask duration:(float) duration;
-(void) set_scale:(float)scalex:(float) scaley;
-(void) set_collision_filter:(int)mask  cat:(int) cat;
-(void) heal:(float)health;
-(void) set_position: (float)x y:(float)y;
-(void) set_rotation: (float)rotat;
-(void) set_zorder: (int) z;
-(SpriteHitProxy*) get_hitproxy;
-(void) dead;
-(bool) isdead;

-(void) cleanup;
-(void) dealloc;
-(void) blink:(float)duration;
-(void) read_sprite_spawn_param:(NSDictionary*) params;

-(int)	collied_with: (SpriteBase *) other  :(struct Collision*) collision;
-(int)	init_with_xml: (NSString*)filename;
-(id)	init_with_spawn_params:(NSDictionary*) params;

-(void)	init_shader;

//logic
-(void) apply_damage:(float) dmg collision:(struct Collision*) collision;
-(void) on_health_empty;
-(void) remove_from_game:(bool) dead;

//spritecomponents
-(int) sprite_components_count;
-(PhysicsSprite*) get_sprite_component: (int) index;
-(void) add_drop_desc:(drop_desc) desc;

-(void) set_physic_position:(int) component :(CGPoint) pos;
-(void) set_physic_angular_velocity:(int) component :(float) v;
-(void) set_physic_angular_damping:(int) component :(float) d;
-(void) set_physic_linear_damping :(int) component :(float) damping;
-(void) set_physic_rotation:(int) component :(float) angle;
-(void) set_physic_linear_velocity:(int) component : (float) x :(float) y;
-(void) set_physic_fixed_rotation:(int) component : (bool) fixed;
-(void) apply_linear_impulse:(int) component :(float)speed_x speed_y:(float)speed_y;
-(void) apply_force_center:(int) component :(float)force_x force_y:(float)force_y;
-(float) get_physic_angular_velocity:(int) component ;
-(float) get_physic_rotation:(int) component;
-(CGPoint) get_physic_linear_velocity:(int) component ;
-(void) clamp_physic_maxspeed:(int) component :(float) max_speed;
-(void) set_layer:(GameLayer*) layer;
-(GameLayer*) get_layer;
//editor interface
-(void) set_selected :(bool) selected;
@end

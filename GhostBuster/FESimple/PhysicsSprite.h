//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "cocos2d.h"
#include <vector>
@class GameLayer;
struct anim_sequence_def
{
    int cell_w;
    int cell_h;
    int cell_pad_x;
    int cell_pad_y;
    int cells_per_line;
    int frame_cnt;
    int offset_x;
    int offset_y;
    float   frame_speed;//fps
    bool    animated;
	NSString*	frame_names;
    NSString*   filename;
    NSString*   anim_name;
    //CCAction*   act;
	anim_sequence_def()
	{
		frame_names = filename = anim_name = NULL;
	}
};



struct phy_shape_def
{
    int type;
    float offset_x;
    float offset_y;
    float rotation;
    bool  is_sensor;
	bool  is_dynamic;
	int	  index;
    union
    {
        float w;
        float radius;
    };
    float h;
	std::vector<float> float_array;
};



struct phy_body_def
{
	int	type;//
	NSString* identity;
	CGPoint offset;
	float	rotation;
	CGPoint anchor_point;
	std::vector<phy_shape_def>	m_phy_shapes;
	int	collision_group;
	int collision_filter;
    float restitution;
	phy_body_def()
	:type(0),identity(NULL),restitution(0),collision_group(0),collision_filter(0)
	{
		offset.x = offset.y = 0;
		anchor_point.x = anchor_point.y = 0.5;
	}
};

enum phy_shape_type
{
    pst_box,
    pst_circle,
	pst_polygon
};

typedef std::vector<phy_shape_def> PHY_SHAPES;
typedef std::vector<phy_body_def> PHY_BODIES;
typedef std::vector<anim_sequence_def> ANIM_SEQUENCES;

struct spr_anim_def
{
	std::vector<anim_sequence_def>	m_anim_sequences;
};

struct sprite_component_def
{
	phy_body_def					m_phy_body;
	spr_anim_def					m_spr_anim;
};

struct sprite_part_def
{
	NSString*						m_desc;
	CGPoint							m_offset;
	float							m_rotation;
	sprite_part_def()
	{
		m_desc = NULL;
	}
};

struct sprite_joint_def
{
	int component_a;
	int component_b;
	int joint_type;
	bool	joint_flags[10];
	float	joint_params[10];
};

typedef std::vector<sprite_part_def> SPRITEPARTDEFS;
typedef std::vector<sprite_joint_def> SPRITEJOINTDEFS;
struct sprite_def
{
	std::vector<sprite_part_def>	m_parts;
	std::vector<sprite_joint_def>	m_joints;
};

@class SpriteBase;
@interface PhysicsSprite : CCSprite
{
	struct b2Body *			m_phy_body_;	// strong ref
	int						m_zorder_;
	CGPoint					m_offset_;
	CGPoint					m_position_;
	float					m_rotation_;
	NSMutableDictionary*	m_anim_sequences_;
	CCAction*				m_current_anim_sequence_;
	SpriteBase*				m_parent_;
	sprite_component_def*	m_component_def;//weak ref
    float                   m_color_override_endtime_;
	float					m_color_mask_;
	ccColor4F				m_mask_color_;
}
@property (nonatomic, assign) float		m_color_override_endtime;
@property (nonatomic, assign) float		m_color_mask;
@property (nonatomic, assign) ccColor4F m_mask_color;
@property (nonatomic, assign) int		m_zorder;
@property (nonatomic, assign) CGPoint	m_position;
@property (nonatomic, assign) float		m_rotation;
@property (nonatomic, assign) SpriteBase* m_parent;
@property (nonatomic, assign) CGPoint	m_offset;
@property (nonatomic, readonly) struct b2Body* m_phy_body;

-(void) set_color_override :( ccColor4F ) color mask:(float) mask duration:(float) duration;
-(void) set_shader_parameter:(const GLchar*)name param_color:(ccColor4F) c;
-(void) set_shader_parameter:(const GLchar*)name param_f1:(float) f1;
-(void) set_phy_body:(struct b2Body*)body;

-(void)	play_anim_sequence:(NSString*) name;
-(void) set_physic_position:(CGPoint) pos;
-(void) set_physic_angular_velocity:(float) v;
-(void) set_physic_angular_damping:(float) d;
-(void) set_physic_linear_damping :(float) damping;
-(void) set_physic_rotation:(float) angle;
-(void) set_physic_linear_velocity: (float) x :(float) y;
-(void) set_physic_fixed_rotation: (bool) fixed;
-(void) apply_linear_impulse:(float)speed_x speed_y:(float)speed_y;
-(void) apply_force_center:(float)force_x force_y:(float)force_y;
-(void) apply_torque:(float)t;
-(float) get_physic_rotation;
-(float) get_physic_angular_velocity;
-(CGPoint) get_physic_linear_velocity;
-(void) clamp_physic_maxspeed: (float) max_speed;

-(void) sync_physic_to_sprite;

-(int) init_by_sprite_component_def:(struct sprite_component_def*) def;

-(void) set_collision_filter:(int)mask  cat:(int) cat;
-(void) set_scale:(float) scalex :(float)scaley;

-(CGRect) world_bounding_box;
-(CGRect) layer_bounding_box;
-(GameLayer*) get_layer;
@end
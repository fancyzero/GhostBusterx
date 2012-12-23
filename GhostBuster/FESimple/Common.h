//
//  Common.m
//  shotandrun
//
//  Created by Fancy Zero on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
@class Hero;
@class CCParticleSystem;
@class CCNode;
float dir_to_angle( CGPoint dir );
CGPoint angle_to_dir( float angle );
bool normalize_point( CGPoint* pt );
CGPoint calc_dir( CGPoint p1, CGPoint p2 );
bool is_in_rect( CGPoint pt, CGRect rc );
float vector_len( const CGPoint* v );
void clamp_vector_len( CGPoint* v, float len );
void log_out( int type, int level, NSString* format, ... );
void play_sfx( NSString* name );
CGPoint get_dir_from_2vector( CGPoint a, CGPoint b );//a to b
float rotate_to_angle( float from, float to, float step, int perfer_dir );
float read_float_value(NSDictionary* params, NSString* key);
bool read_bool_value(NSDictionary* params, NSString* key);
CGPoint read_CGPoint_value(NSDictionary* params, NSString* key, CGPoint default_value);
int read_int_value(NSDictionary* params, NSString* key);
NSArray* read_float_array(NSDictionary* params, NSString* key);
bool device_is_landscape();
float current_game_time();
bool is_outof_map(CGPoint pos, float radius);
bool is_outof_acting_range(CGPoint pos, float radius);
bool is_outof_acting_range( CGPoint pos, CGRect bounding_box );
bool is_outof_acting_range( CGPoint pos, CGRect bounding_box, float move_scale );
void play_music(NSString* filename);
CCParticleSystem* play_particle( NSString* filename, CGPoint pos , int z);
CCParticleSystem* play_particle( NSString* filename, CGPoint pos , int z, CCNode* parent, int postype = 0);
Hero* get_player(int index);
CGRect current_acting_range();
float current_level_progress();
void* get_input_device();
enum collison_group_def
{
	cg_player1=1,
	cg_player2=2,
	cg_enemy=4,
	cg_static=8,
	cg_enemy_bullet=16,
	cg_acting_range=32,
	cg_pickup=64,
};

int collision_filter_enemy_bullet();
int collision_filter_enemy();
int collision_filter_player();
int collision_filter_players_pickup();
int collision_filter_player_bullet();

int string_to_collision_filters(NSString* str);
int string_to_collision_categories(NSString* str);
@class CCNode;
CGPoint convert_local_to_layer_space( CCNode* node, CGPoint local_point);
CGAffineTransform convert_transform_to_layer_space( CCNode* node );
struct b2Vec2 PTM_vec2(const CGPoint& p);
CGPoint MTP_vec2(const struct b2Vec2& p);
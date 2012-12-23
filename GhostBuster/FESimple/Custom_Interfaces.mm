
//
//  Custom_Interfaces.cpp
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-8-16.
//
//
#import <Foundation/Foundation.h>
#include "Custom_Interfaces.h"
#include "Common.h"

void load_sprite_spawn_param( struct sprite_spawn_param* param, NSDictionary* params )
{
	CGPoint def_value;
	def_value.x = def_value.y = 0;
	//int sss = sizeof(sprite_spawn_param);
	param->init_pos_rel_act = read_bool_value(params, @"init_pos_rel_act");
	param->init_position = read_CGPoint_value(params, @"init_position",def_value);
	param->init_force = read_float_value( params ,@"init_force");
	param->init_fixed = read_bool_value(params ,@"init_fixed" );
	if ( [params objectForKey:@"init_move_dir"] != NULL )
		param->init_move_dir = read_CGPoint_value(params ,@"init_move_dir",def_value );
	else
		param->init_move_dir = def_value;
	
	normalize_point( &param->init_move_dir);
	param->init_move_speed = read_float_value (params ,@"init_move_speed");
	param->init_rotation =read_float_value (params ,@"init_rotation");
	param->move_dest = read_CGPoint_value(params ,@"move_dest",def_value );
	param->sprite_desc = [params valueForKey: @"sprite_desc"];
	param->collision_cat = string_to_collision_categories([params valueForKey:@"collision_categories"]);
	param->collision_filter = string_to_collision_filters([params valueForKey:@"collision_filters"]);
	if ( [params objectForKey:@"init_scale"] != NULL )
		param->init_scale = [[params valueForKey:@"init_scale"] floatValue];
	else
		param->init_scale = 1;
	param->layer = [params valueForKey:@"layer"];
	if ( [params objectForKey:@"init_zorder"] != NULL )
		param->init_zorder = [[params valueForKey:@"init_zorder"] intValue];
	else
		param->init_zorder = 3;
}
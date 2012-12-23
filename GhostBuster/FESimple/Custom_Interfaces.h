//
//  Custom_Interfaces.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-8-16.
//
//

#ifndef ShotAndRun4_Custom_Interfaces_h
#define ShotAndRun4_Custom_Interfaces_h
#import <Foundation/Foundation.h>


struct sprite_spawn_param
{
	CGPoint	init_position;
	CGPoint init_move_dir;
	float	init_move_speed;
	float	init_rotation;
	CGPoint	move_dest;
	float	init_force;
	NSString*	sprite_desc;
	int		collision_filter;
	int		collision_cat;
	NSString*	layer;
	float	init_scale;
	int		init_zorder;
	bool	use_init_force:1;
	bool	init_fixed:1;
	bool	init_pos_rel_act:1;

	
};

void load_sprite_spawn_param( struct sprite_spawn_param* param, NSDictionary* params );
#endif

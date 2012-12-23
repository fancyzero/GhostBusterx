//
//  Common.m
//  shotandrun
//
//  Created by Fancy Zero on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "Common.h"
#import "Simpleaudioengine.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "Level.h"
#import "GameScene.h"
#import "World.h"
#import "GameBase.h"

float dir_to_angle( CGPoint dir )
{
    float ret;
    if ( dir.x == 0 )
    {
        if ( dir.y > 0 )
            ret = 90;
        else
            ret = -90;
    }
    else if ( dir.y == 0 )
    {
        if ( dir.x > 0 )
            ret = 0;
        else
            ret = 180;
    }
    else
    {
        float sinval = dir.y / sqrtf(dir.y*dir.y + dir.x * dir.x);
        ret = (asinf(sinval))*57.29577951f;
        if ( dir.x < 0 )
            ret = 180 - ret;
    }    
    return ret;
}

bool is_in_rect( CGPoint pt, CGRect rc )
{
    if ( pt.x > rc.origin.x + rc.size.width )
        return false;
    if ( pt.y > rc.origin.y + rc.size.height )
        return false;
    if ( pt.x < rc.origin.x )
        return false;
    if ( pt.y < rc.origin.y )
        return false;
    return true;
}

CGPoint angle_to_dir( float angle )
{
    angle = fmodf(angle, 360.0f);
    if ( angle < 0 )
        angle += 360.0f;
    if ( angle == 0 )
        return CGPointMake(1, 0);
    if ( angle == 90 )
        return CGPointMake(0, 1);
    if ( angle == 180 )
        return CGPointMake(-1, 0);
    if ( angle == 270 )
        return CGPointMake(0, -1);
    float rad = angle * 0.01745329252f;
    float x;
    float y;
    x = 1;
    y = tanf( rad );    
    if ( angle > 180 )
        y = - fabs(y);
    else
        y = fabs(y);
    if ( angle >90 && angle < 270 )
        x = - fabs(x);
    else
        x = fabs(x);
    
    CGPoint pt = CGPointMake(x, y);
    normalize_point( &pt );
    return pt;
}

bool normalize_point( CGPoint* pt )
{
    float len = sqrtf((pt->x*pt->x) + (pt->y*pt->y));
	if ( len != 0 )
	{
		pt->x = pt->x / len;
		pt->y = pt->y / len;
	}
    return true;
}


float vector_len( const CGPoint* v )
{
    return sqrtf((v->x*v->x) + (v->y*v->y));
}
void clamp_vector_len( CGPoint* v, float len )
{
    float _len = vector_len(v);
    if ( _len > len )
    {
        normalize_point(v);
        v->x *= len;
        v->y *= len;
    }
}

CGPoint calc_dir( CGPoint p1, CGPoint p2 )
{
    return CGPointMake(p2.x - p1.x, p2.y - p1.y);
}

void log_out( int type, int level, NSString* format, ... )
{

}

float current_game_time()
{
	return [GameBase current_time];
}


void play_music(NSString* filename)
{
    SimpleAudioEngine* eng = [SimpleAudioEngine sharedEngine];
    [ eng playBackgroundMusic:filename loop:true];
}

void play_sfx( NSString* name )
{
    SimpleAudioEngine* eng = [SimpleAudioEngine sharedEngine];
    [ eng playEffect:name];
}


CGPoint get_dir_from_2vector( CGPoint from, CGPoint to )
{
	from.x = to.x - from.x;
	from.y = to.y - from.y;
	normalize_point(&from);
	return from;
}

float rotate_to_angle( float from, float to, float step, int perfer_dir )
{
	from = fmodf( from, 360 );
	to = fmodf( to, 360 );

	if ( from < 0 )
		from += 360;
	if ( to < 0 )
		to  += 360;
	
	float dist = from - to;
	if ( fabsf(dist) < step )
		return to;
	dist = fmodf( dist, 360);
	if ( dist < 0 )
		dist += 360;
	if ( dist <= 180 )
		from -= step;
	else
		from += step;

	return from;
}

float read_float_value(NSDictionary* params, NSString* key)
{
	return [[params valueForKey:key] floatValue];
}

bool read_bool_value(NSDictionary* params, NSString* key)
{
	return [[params valueForKey:key] boolValue];
}

int read_int_value(NSDictionary* params, NSString* key)
{
	return [[params valueForKey:key] intValue];
}

NSArray* read_float_array(NSDictionary* params, NSString* key)
{
	return [[ params valueForKey:key] componentsSeparatedByString:@","];
}

CGPoint read_CGPoint_value(NSDictionary* params, NSString* key, CGPoint default_value)
{
	CGPoint pt;
	pt.x = 0;
	pt.y = 0;
	if ( [params objectForKey:key ] == NULL )
		return default_value;
	NSArray* numbers=[[ params valueForKey:key] componentsSeparatedByString:@","];
	if ( [numbers count] >= 2)
	{
		pt.x  = [[ numbers objectAtIndex:0] floatValue];
		pt.y = [[ numbers objectAtIndex:1] floatValue];
	}
	//NSLog( @"number: %d", [numbers retainCount]);
	//[ numbers release];
	return pt;
}
	
int string_to_collision_category(NSString* str)
{
	if ( [str isEqualToString:@"player1"])
	{
		return cg_player1;
	}
	if ( [str isEqualToString:@"player2"])
	{
		return cg_player2;
	}
	if ( [str isEqualToString:@"enemy"])
	{
		return cg_enemy;
	}
	if ( [str isEqualToString:@"static"])
	{
		return cg_static;
	}
	if ( [str isEqualToString:@"enemy_bullet"])
	{
		return cg_enemy_bullet;
	}
	NSLog(@"[warning] unrecognized collision category: %@", str);
	assert(0);
	return 0;
}

int string_to_collision_filter(NSString* str)
{
	
	if ( [str isEqualToString:@"enemy_bullet"])
	{
		return cg_enemy_bullet;
	}
	if ( [str isEqualToString:@"player1"])
	{
		return cg_player1;
	}
	if ( [str isEqualToString:@"player2"])
	{
		return cg_player2;
	}
	if ( [str isEqualToString:@"enemy"])
	{
		return cg_enemy;
	}
	if ( [str isEqualToString:@"static"])
	{
		return cg_static;
	}
	if ( [str isEqualToString:@"players"])
	{
		return cg_player1 | cg_player2;
	}
	if ( [str isEqualToString:@"enemy_bullet"])
	{
		return collision_filter_enemy_bullet();
	}
	if ( [str isEqualToString:@"enemy"])
	{
		return collision_filter_enemy_bullet();
	}
	if ( [str isEqualToString:@"player"])
	{
		return collision_filter_enemy_bullet();
	}
	if ( [str isEqualToString:@"player_bullet"])
	{
		return collision_filter_enemy_bullet();
	}
	NSLog(@"[warning] unrecognized collision filter: %@", str);
	assert(0);
	return 0;

}


int string_to_collision_filters(NSString* str)
{
	NSArray* filters=[ str componentsSeparatedByString:@"," ];
	if ( [filters count] <= 0 )
		return 0;
	int ret = 0;
	
	for ( int i = 0; i < [filters count]; i++ )
	{
		ret |= string_to_collision_filter([filters objectAtIndex:i] );
	}
	return ret;
}

int string_to_collision_categories(NSString* str)
{
	NSArray* cats=[ str componentsSeparatedByString:@"," ];
	if ( [cats count] <= 0 )
		return 0;
	int ret = 0;

	for ( int i = 0; i < [cats count]; i++ )
	{
		ret |= string_to_collision_categories([cats objectAtIndex:i] );
	}
	return ret;
}

int collision_filter_enemy_bullet()
{
	return (cg_player1 | cg_player2 | cg_static);
}

int collision_filter_enemy()
{
	return (cg_player1 | cg_player2 | cg_static);
}
int collision_filter_player()
{
	return (cg_enemy | cg_enemy_bullet | cg_static | cg_acting_range | cg_pickup);
}
int collision_filter_players_pickup()
{
	return (cg_player1 | cg_player2  );
}
int collision_filter_player_bullet()
{
	return (cg_enemy | cg_static );
}

CGPoint convert_local_to_layer_space( CCNode* node, CGPoint local_point)
{
	CGAffineTransform t = convert_transform_to_layer_space(node);


	return ccp(t.tx + t.a * local_point.x + t.c * local_point.y, t.ty + t.d * local_point.y + t.b * local_point.x);
}

CGAffineTransform convert_transform_to_layer_space( CCNode* node )
{
	CGAffineTransform t = [node nodeToParentTransform];
	
	for (CCNode *p = node.parent; p != nil; p = p.parent)
	{
		if ( [p isKindOfClass: [CCLayer class]] )
			break;
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);
	}
	return t;
}

struct b2Vec2 PTM_vec2(const CGPoint& p)
{
	b2Vec2 ret;
	ret.x = p.x / [GameBase get_ptm_ratio];
	ret.y = p.y / [GameBase get_ptm_ratio];
	return ret;
}

CGRect current_acting_range()
{
    GameBase* game = [GameBase get_game];
	return game.m_level.m_acting_range;
};

CGPoint MTP_vec2(const struct b2Vec2& p)
{
	return ccp( p.x * [GameBase get_ptm_ratio], p.y * [GameBase get_ptm_ratio] );
}

bool device_is_landscape()
{
#ifndef __CC_PLATFORM_MAC
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if ( UIInterfaceOrientationIsLandscape(orientation) )
	{
		return true;
	}
	else
		return false;
#else
	return true;
#endif
}
CCParticleSystem* play_particle( NSString* filename, CGPoint pos , int z)
{
	CCParticleSystem* exp;
	exp = [CCParticleSystemQuad particleWithFile:filename];
	exp.autoRemoveOnFinish = YES;
	exp.positionType = kCCPositionTypeFree;
	[exp setPosition:pos];
	[[ GameBase get_game ].m_scene.m_layer addChild:exp z:z ];
	return exp;
}

CCParticleSystem* play_particle( NSString* filename, CGPoint pos , int z, CCNode* parent, tCCPositionType postype )
{
	CCParticleSystem* exp;
	exp = [CCParticleSystemQuad particleWithFile:filename];
	exp.autoRemoveOnFinish = YES;
	exp.positionType = postype;
	[exp setPosition:pos];
	if ( parent == NULL )
		[[ GameBase get_game ].m_scene.m_layer addChild:exp z:z ];
	else
		[parent addChild:exp z:z ];
	return exp;
}

float current_level_progress()
{
	if ( [ GameBase get_game].m_level != NULL )
		return [ GameBase get_game].m_level.m_level_progress;
	else
		return 0;
}

bool is_outof_map( CGPoint pos, float radius )
{
	if ( [GameBase get_game].m_level == NULL)
		return false;
    CGRect bound = [ GameBase get_game].m_level.m_map_rect;
	bound.origin.x -= radius;
	bound.origin.y -= radius;
	bound.size.width += radius;
	bound.size.height += radius;
	return !is_in_rect(pos, bound);
}
bool is_outof_acting_range( CGPoint pos, float radius )
{
	if ( [GameBase get_game].m_level == NULL)
		return false;
    CGRect bound = [ GameBase get_game].m_level.m_acting_range;
	bound.origin.x -= radius;
	bound.origin.y -= radius;
	bound.size.width += radius;
	bound.size.height += radius;
	return !is_in_rect(pos, bound);
}

bool is_outof_acting_range( CGPoint pos, CGRect bounding_box, float move_scale )
{
	if ( [GameBase get_game].m_level == NULL)
		return false;
	//bounding_box.origin;
    CGRect bound = [ GameBase get_game].m_level.m_acting_range;
	bound.origin = ccpMult( bound.origin, move_scale );
	
	return !CGRectIntersectsRect(bounding_box, bound) ;
}

bool is_outof_acting_range( CGPoint pos, CGRect bounding_box )
{
	if ( [GameBase get_game].m_level == NULL)
		return false;
	//bounding_box.origin;
    CGRect bound = [ GameBase get_game].m_level.m_acting_range;

	
	return !CGRectIntersectsRect(bounding_box, bound) ;
}

Hero* get_player(int index)
{
	GameBase* game = [GameBase get_game];
	Hero* hero = (Hero*)[ game.m_world find_obj_by_name:@"Hero" ];
	return hero;
}
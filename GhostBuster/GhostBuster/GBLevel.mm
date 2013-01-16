//
//  GBLevel.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//
#import "cocos2d.h"
#import "GBLevel.h"
#import "GameBase.h"
#import "World.h"
#import "Common.h"
#import "GameScene.h"
#import "SPlayer.h"
#import "sghost.h"
#include "Box2D.h"
#import "PhysicsDebuger.h"
#import "LevelCollider.h"
#import "SPickup.h"
#import "GBGame.h"
#import "SPlayer.h"
@implementation GBLevel
@synthesize m_grid_size;

-(b2Body*) setup_level_collider:(PhysicsSprite*) collider_spr
{
	b2BodyDef bd;
	bd.type = b2_staticBody;
	bd.position = b2Vec2(0,0);
	
	b2Body* body = [GameBase get_game].m_world.m_physics_world->CreateBody(&bd);
	for( int y = 0; y < m_tiled_map.mapSize.height; y++ )
	{
		for( int x = 0; x < m_tiled_map.mapSize.width; x++ )
		{
			if ( [self isWallAtTileCoord:ccp(x,y)])
			{
				
				
				b2PolygonShape s;
				CGPoint center = [self positionForTileCoord:ccp(x,y)];
				b2Vec2 boxcenter;
				boxcenter.x =  center.x / [GameBase get_ptm_ratio];
				boxcenter.y =  center.y / [GameBase get_ptm_ratio];
				s.SetAsBox( m_grid_size/ [GameBase get_ptm_ratio]/2, m_grid_size/ [GameBase get_ptm_ratio]/2, boxcenter, 0);
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &s;
				fixtureDef.isSensor = false;
				fixtureDef.userData = collider_spr;
				fixtureDef.density = 1;
				fixtureDef.restitution = 0.5;
				fixtureDef.friction = 0;
				body->CreateFixture(&fixtureDef);
				
			}
		}
	}

	[collider_spr set_phy_body:body];
	return body;
}

-(void) reset
{
	
	[super reset];
	[[[CCDirector sharedDirector] touchDispatcher] removeAllDelegates];
	GBGame* game =(GBGame*) [GameBase get_game];
    m_cross_spawn_rate = [[ game get_config_value:@"cross_spawn_interval"] floatValue];

	m_spawn_cross_time = 0;
	game_state = 0;
	if ( m_level_collider )
		[m_level_collider release];
	m_walkable_tiles.clear();
    m_game_end_time = current_game_time() + [[ game get_config_value:@"game_duration"] floatValue];;
    m_restart_after = 0;
	[m_tiled_map release];

    [ game cleanup_world ];
	m_walkableAdjacent_cache.clear();

	m_tiled_map = [CCTMXTiledMap tiledMapWithTMXFile:@"levels/map1.tmx"];
	m_grid_size = m_tiled_map.tileSize.width ;
	[m_tiled_map retain];
	[game.m_scene.m_layer addChild:m_tiled_map];
	SPlayer* p;
    p = [[SPlayer alloc] init_with_id:0];
	CGPoint pt = [self positionForTileCoord:ccp(7,4)];
    [ p set_position:pt.x y:pt.y];
    [p set_id:0];
	
    p = [[SPlayer alloc] init_with_id:1];
    pt = [self positionForTileCoord:ccp(7,5)];
    [ p set_position:pt.x y:pt.y];
    [p set_id:1];
    
    p = [[SPlayer alloc] init_with_id:2];
    pt = [self positionForTileCoord:ccp(8,4)];
    [ p set_position:pt.x y:pt.y];
    [p set_id:2];
    
    p = [[SPlayer alloc] init_with_id:3];
    pt = [self positionForTileCoord:ccp(8,5)];
    [ p set_position:pt.x y:pt.y];
    [p set_id:3];
    
    int ghostcount = [[ game get_config_value:@"ghost_count"] intValue];
    for ( int i = 0 ; i < ghostcount; i++ )
    {
        int x = 0;
        int y = 0;
        while(1)
        {
			if ( rand()%2)
				x = rand() % 5;
			else
				x = rand()%5 + 10;
			if ( rand()%2)
				y = rand() % 3;
			else
				y = rand()%3 + 7;
            if ( ![self isWallAtTileCoord:ccp(x,y)])
                break;
        }
		SGhost* g = [SGhost new];
		pt = [self positionForTileCoord:ccp(x,y)];
		[ g set_position:pt.x y:pt.y];
    }
	for( int y = 0; y < m_tiled_map.mapSize.height; y++ )
	{
		for( int x = 0; x < m_tiled_map.mapSize.width; x++ )
		{
			NSArray* arr = [self get_walkableAdjacentTilesCoordForTileCoord:CGPoint(ccp(x,y))];
			[arr retain];
			m_walkableAdjacent_cache.push_back(arr);
		}
	}
	for( int y = 0; y < m_tiled_map.mapSize.height; y++ )
	{
		for( int x = 0; x < m_tiled_map.mapSize.width; x++ )
		{
			if ( ![self isWallAtTileCoord:ccp(x,y) ])
				m_walkable_tiles.push_back(ccp(x,y)) ;
		}
	}
	
	m_level_collider = [LevelCollider new];
	[m_level_collider init_by_level:self];

	m_spawn_cross_time = current_game_time() +  [[ game get_config_value:@"cross_first_spawn_time"] floatValue];;
	if ( 0 )
	{
		physics_debug_sprite* pds = [ physics_debug_sprite new ];
		pds.zOrder = 200;
		[[GameBase get_game].m_scene.m_layer addChild:pds ];
	}
}

-(bool) pending_restart
{
    return m_restart_after > 0;
}
-(CGSize) get_mapsize
{
	return m_tiled_map.mapSize;
}

-(void)update:(float)delta_time
{
    [ super update:delta_time];
	
	
	if ( m_restart_after > 0 )
    {
		
		
        if (m_restart_after < current_game_time())
            [self reset];
		
        return;
    }
	if ( m_spawn_cross_time < current_game_time() )
	{
		SPickup * p = [SPickup new];
		CGPoint desttile;
		desttile = m_walkable_tiles[rand() % m_walkable_tiles.size()];
		CGPoint pos = [self positionForTileCoord:desttile];
		[ p set_physic_position:0 :pos ];
		m_spawn_cross_time = current_game_time() + m_cross_spawn_rate;

	}
	
	// update acting range
	//todo: optmize
	std::vector<level_acting_range_keyframe>::const_iterator i;
	level_acting_range_keyframe a,b;
	
	for ( i = m_acting_range_keyframes_.begin(); i != m_acting_range_keyframes_.end(); ++i)
	{
		b = *i;
		if ( b.progress >= m_level_progress_ )
			break;
	}
	if ( i != m_acting_range_keyframes_.begin())
	{
		a = (*(i-1));
		CGRect rc_act;
		if ( b.progress == a.progress )
		{
			[self set_acting_range:b.act_rect];
			self->m_acting_range_velocity_ = ccp(0,0);
		}
		else
		{
			float alpha = (m_level_progress_ - a.progress) / (b.progress - a.progress);
			rc_act.origin.x = a.act_rect.origin.x * (1- alpha) + b.act_rect.origin.x * alpha;
			rc_act.origin.y = a.act_rect.origin.y * (1- alpha) + b.act_rect.origin.y * alpha;
			rc_act.size.width = a.act_rect.size.width * (1- alpha) + b.act_rect.size.width * alpha;
			rc_act.size.height = a.act_rect.size.height * (1- alpha) + b.act_rect.size.height * alpha;
			self->m_acting_range_velocity_.x = (b.act_rect.origin.x - a.act_rect.origin.x) / (b.progress - a.progress);
			self->m_acting_range_velocity_.y = (b.act_rect.origin.y - a.act_rect.origin.y) / (b.progress - a.progress);
			[self set_acting_range:rc_act];
		}
		
	}
	else
	{
		[self set_acting_range:b.act_rect];
	}
	
    GameBase* game = [GameBase get_game];
	
	if ( super.m_current_trigger < m_level_triggers.size() )
	{
		for ( int i = super.m_current_trigger; i < m_level_triggers.size(); ++i )
		{
			if ( m_level_triggers[i].action_type == ta_addobj )
			{
				if ( m_level_triggers[i].progress_pos < self.m_level_progress )
				{
					Class c = NSClassFromString(m_level_triggers[i].script);
					assert( [c isSubclassOfClass:[GameObjBase class]]);
					GameObjBase* object = [[ c alloc] init_with_spawn_params:m_level_triggers[i].params];
					if ( [m_level_triggers[i].params objectForKey:@"layer"] != NULL )
						[game.m_world add_gameobj:object layer:[m_level_triggers[i].params valueForKey:@"layer"] ];
					else
						[game.m_world add_gameobj:object  ];
					//[game add_game_obj_by_classname:m_level_triggers[i].script pos_x:0 pos_y:0];
					super.m_current_trigger = i+1;
				}
				else
					break;
			}
			if ( m_level_triggers[i].action_type == ta_rand_addobj )
			{
				if ( m_level_triggers[i].progress_pos < self.m_level_progress )
				{
					Class c = NSClassFromString(m_level_triggers[i].script);
					assert( [c isSubclassOfClass:[GameObjBase class]]);
					
					int count = read_int_value(m_level_triggers[i].params, @"rand_add_count");
					CGPoint orig = read_CGPoint_value(m_level_triggers[i].params, @"rand_add_orig", ccp(0,0));
					CGPoint range = read_CGPoint_value(m_level_triggers[i].params, @"rand_add_range", ccp(0,0));
					float scale_base = read_float_value(m_level_triggers[i].params, @"rand_add_scale_base");
					float scale_range = read_float_value(m_level_triggers[i].params, @"rand_add_scale_range");
					for ( int j = 0; j < count; j++ )
					{
						float s = (scale_base + (rand()/float(RAND_MAX))*scale_range);
						NSMutableString* val = [NSString stringWithFormat:@"%f" ,s];
						
						[m_level_triggers[i].params setObject:val forKey:@"init_scale"];
						val =[NSString stringWithFormat:@"%d", rand()%360];
						[m_level_triggers[i].params setObject:val forKey:@"init_rotation"];
						val =[NSString stringWithFormat:@"%f,%f", orig.x + rand()%(int)range.x, orig.y + rand()%(int)range.y];
						[m_level_triggers[i].params setObject:val forKey:@"init_position"];
						GameObjBase* object = [[ c alloc] init_with_spawn_params:m_level_triggers[i].params];
						
						
						
						if ( [m_level_triggers[i].params objectForKey:@"layer"] != NULL )
							[game.m_world add_gameobj:object layer:[m_level_triggers[i].params valueForKey:@"layer"] ];
						else
							[game.m_world add_gameobj:object  ];
					}
					//[game add_game_obj_by_classname:m_level_triggers[i].script pos_x:0 pos_y:0];
					super.m_current_trigger = i+1;
				}
				else
					break;
			}
		}
	}
	
	if ( m_game_end_time < current_game_time() )
	{
		float highestscore = -1;
		SPlayer* highestplayer = NULL;
		NSMutableArray* tmp = [game.m_world find_objs_by_classname:@"SPlayer"];
		for (SPlayer* s in tmp)
		{
			if ( s->m_alive_counter > highestscore )
			{
				highestplayer = s;
				highestscore = s->m_alive_counter;
			}
		}
		if ( highestplayer != NULL )
			[highestplayer set_scale:2 :2];
		m_restart_after = current_game_time() + 5;

	}
}

-(void) dealloc
{
	[m_level_collider release];
	
	[ super dealloc];
	std::vector<level_progress_trigger>::iterator it;
	for ( it = m_level_triggers.begin(); it != m_level_triggers.end(); it++)
	{
		[(*it).params release];
		[(*it).script release];
	}
	m_level_triggers.clear();

}
-(void) on_sprite_dead: (SpriteBase*) sprite
{
	
}
-(void) on_remove_obj: (GameObjBase*) obj
{
}
-(void) on_sprite_spawned: (SpriteBase*) sprite
{
}
-(void) on_add_obj: (GameObjBase*) obj
{
}
-(void) on_level_start
{
}


- (CGPoint)tileCoordForPosition:(CGPoint)position
{
	CGPoint pt;
	pt.x = floorf(position.x / m_grid_size);
	pt.y = floorf((768 - position.y) / m_grid_size );
	return pt;
}
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord
{
	CGPoint pt;
	pt.x = tileCoord.x * m_grid_size + m_grid_size/2;
	pt.y = (768 - tileCoord.y * m_grid_size ) - m_grid_size/2;
	return pt;
}

-(bool) isValidTileCoord:(CGPoint) pt;
{
	if ( pt.x >=0 && pt.y >= 0 && pt.x < m_tiled_map.mapSize.width && pt.y < m_tiled_map.mapSize.height )
		return true;
	return false;
}

-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer {
    if (![self isValidTileCoord:tileCoord]) return NO;
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [m_tiled_map propertiesForGID:gid];
    if (properties == nil) return NO;
    return [properties objectForKey:prop] != nil;
}

-(bool) isWallAtPositionCoord:(CGPoint) pt :(float) radius
{
    for ( int i = -1; i<2; i++ )
    {
        for ( int j = -1; j<2; j++ )
        {
            CGPoint pt2 = [ self tileCoordForPosition:pt];
            pt2.x += i;
            pt2.y += j;
            CGPoint tilepos;
            tilepos = [ self positionForTileCoord:pt2];
            CGPoint distance_to_tile_center = ccpSub(pt, tilepos);
            
            if ( abs(distance_to_tile_center.x) <= radius +m_grid_size/2 && abs(distance_to_tile_center.y) <= radius+ m_grid_size/2 )
            {
                if ( [self isWallAtTileCoord:(pt2)] || ![self isValidTileCoord:pt2])
                    return true;
            }
        }
    }
    return false;
}

-(bool) isWallAtTileCoord:(CGPoint) pt
{
	CCTMXLayer* layer = [m_tiled_map layerNamed:@"layer1"];
	BOOL ret = [self isProp:@"wall" atTileCoord:pt forLayer:layer];
	//NSLog(@"%f,%f : %d",pt.x,pt.y,ret);
	return ret;
}

- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
	int x = tileCoord.x;
	int y = tileCoord.y;
	return m_walkableAdjacent_cache[x+y*m_tiled_map.mapSize.width];
}

- (NSArray *)get_walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:8];
	
    BOOL t = NO;
    BOOL l = NO;
    BOOL b = NO;
    BOOL r = NO;
	
	// Top
	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        t = YES;
	}
	
	// Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        l = YES;
	}
	
	// Bottom
	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        b = YES;
	}
	
	// Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        r = YES;
	}
    
    
	// Top Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y - 1);
	if (t && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y + 1);
	if (b && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Top Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y - 1);
	if (t && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y + 1);
	if (b && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
    
	return [NSArray arrayWithArray:tmp];
}

-(bool) raycast:(CGPoint) start :(CGPoint) end
{
	float x;
	int starty, endy;
	int startx, endx;
	
	startx = [self tileCoordForPosition :start ].x;
	starty = [self tileCoordForPosition :start ].y;
	endx = [self tileCoordForPosition :end ].x;
	endy = [self tileCoordForPosition :end ].y;
	float k = (fabsf(start.x - end.x)+1) / (fabsf(start.y - end.y )+1);
	
	int ydir = 1;
	if ( starty > endy )
		ydir = -1;
	int xdir = 1;
	if ( startx > endx )
		xdir = -1;
	float ka = 0;
	for ( float y = starty; y != endy; y += ydir )
	{
		float kka = k;
		for( int xs = 0; xs < (int)kka; xs++ )
		{
			
		}
	}
	return false;
}
@end

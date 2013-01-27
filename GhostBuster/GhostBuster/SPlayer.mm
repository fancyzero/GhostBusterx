//
//  SPlayer.m
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-16.
//
//
#import	"cocos2d.h"
#import "SPlayer.h"
#import "Common.h"
#import "GameBase.h"
#import "GBLevel.h"
#import "World.h"
#import "SGhost.h"
#import "SPickup.h"
#import "GameScene.h"
#import "GBGame.h"
#import "CCLabelTTF.h"
@implementation SPlayer
-(id) init_with_id:(int) id;
{
	self  = [super init];
	m_score = 0;
	m_dir_controller_length = 20;
	m_alive_counter = 0;
    movedir = ccp(0,0);
    m_inter_collision_radius = 20;
    m_wall_collision_radius = 25;
	GBGame* game =(GBGame*) [GameBase get_game];
    m_speed = [[ game get_config_value:@"player_move_speed"] floatValue];
    
    [self set_id:id];
	//NSLog(@"%@, %d",self ,[self retainCount]);
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:FALSE];
	//NSLog(@"%@, %d",self ,[self retainCount]);
	self.m_name = @"Player";
    if ( id == 0 )
	[self init_with_xml:@"sprites/base.xml:Player1" ];
    if ( id == 1 )
        [self init_with_xml:@"sprites/base.xml:Player2" ];
    if ( id == 2 )
        [self init_with_xml:@"sprites/base.xml:Player3" ];
    if ( id == 3 )
        [self init_with_xml:@"sprites/base.xml:Player4" ];
    
		[self set_scale:0.75 :0.75];
	//[ self set_collision_filter:collision_filter_player()  cat:cg_player1];
	[[GameBase get_game].m_world add_gameobj:self];
	[ self set_zorder:3];
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
    [self set_role:role_player];
	
	[self set_collision_filter:1+2+4+8+16+32+64 cat:1];
	[self set_physic_fixed_rotation:0 :true];
	[self set_physic_mass:0 :1];
	
	
	m_alive_counter_label = [CCLabelTTF labelWithString:@"health:" fontName:@"Courier" fontSize:30];
	[m_alive_counter_label retain];
	CGPoint labelpos;
	if( id == 1 )
	{
		labelpos=ccp(80, 80);
	}
	if( id == 3 )
	{
		labelpos=ccp(1024-80, 80);
	}
	if( id == 0 )
	{
		labelpos=ccp(80, 768-80);
	}
	if( id == 2 )
	{
		labelpos=ccp(1024-80, 768-80);
	}
	[m_alive_counter_label setPosition:labelpos];
	[[GameBase get_game].m_scene.m_UIlayer addChild:m_alive_counter_label z:10];

    [self set_physic_linear_damping:0 :2];
  	return self;
}

-(int) collied_with:(SpriteBase *)other :(struct Collision *)collision
{
	if ( [other isKindOfClass:[GBSpriteBase class]] )
	{
		GBSpriteBase* s = (GBSpriteBase*) other;
		if ( s->m_role == role_ghost )
		{
			[self set_color_override:ccc4f(1, 0, 1, 1) mask:0.5 duration:0xffffffff];
			m_role = role_ghost;
		}
	}
	if ( [other isKindOfClass:[SPickup class]] )
	{
		if ( m_role == role_ghost )
		{
			[self set_color_override:ccc4f(1, 0, 1, 1) mask:0 duration:0xffffffff];
			m_role = role_player;
			[other remove_from_game:true];
		}
	}
	return 0;
}

-(bool) can_moveto:(CGPoint) pt
{
    GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
    bool ret = [level isValidTileCoord:[level tileCoordForPosition:pt]] && ![level isWallAtPositionCoord:pt:m_wall_collision_radius] ;
    if ( !ret )
        return false;
    GameBase* game = [GameBase get_game];
    NSMutableArray* players = [game.m_world find_objs_by_name:@"Player"];
    for (int i = 0; i <  players.count;i++ )
    {
        SPlayer* p = (SPlayer*)[players objectAtIndex:i];
        if ( p == self )
            continue;

        CGPoint v = ccpSub(pt, p.m_position);
        float len = ccpLength(v);
        if ( len < m_inter_collision_radius*2)
        {
            return false;
	
        }
    }
    return true;

}

-(void) update:(float)delta_time
{
	[super update:delta_time	];
	if ( m_role == role_player )
		m_alive_counter += delta_time;
	NSString* temp;
	temp = [NSString stringWithFormat:@"%.2f", m_alive_counter ];
	[m_alive_counter_label setString:temp];
    float movelen = delta_time*m_speed;
	CGPoint pt = ccpMult(movedir, movelen);
	pt = ccpAdd( self.m_position, pt );
	GBLevel* level = (GBLevel*)[GameBase get_game].m_level;
	//if ( [level isValidTileCoord:[level tileCoordForPosition:pt]] && [self can_moveto:pt] )
	//{
    CGPoint force = ccp(movedir.x*m_speed/[GameBase get_ptm_ratio],movedir.y*m_speed/[GameBase get_ptm_ratio]);
    [self apply_force_center:0 :force.x force_y:force.y];

	CGPoint player_tiled_coord = [level tileCoordForPosition: self.m_position];

	if ( [level is_coin:player_tiled_coord] )
	{
		[level remove_coin:player_tiled_coord];
	}
	//	[ self set_physic_linear_velocity:0 :movedir.x*m_speed/[GameBase get_ptm_ratio] :movedir.y*m_speed/[GameBase get_ptm_ratio]];
	//}
   /* else
    {
        CGPoint ptx = pt;
        CGPoint pty = pt;
        ptx.x = self.m_position.x;
        pty.y = self.m_position.y;

        if ( [self can_moveto:ptx ] )
        {
            CGPoint moreptx = self.m_position;
            if ( pt.y > self.m_position.y )
                moreptx.y += movelen;
            else
                moreptx.y -= movelen;
            if ( [self can_moveto:moreptx] )
            [ self set_position:moreptx.x y:moreptx.y];
                else
            [ self set_position:ptx.x y:ptx.y];
        }
        else
            if ( [self can_moveto:pty] )
        {
            CGPoint morepty = self.m_position;
            if ( pt.x > self.m_position.x )
                morepty.x += movelen;
            else
                morepty.x -= movelen;
            if ( [self can_moveto:morepty] )
                [ self set_position:morepty.x y:morepty.y];
            else
                [ self set_position:ptx.x y:ptx.y];
        }
    }
*/
       [ m_sprite_components[0] setFlipX:movedir.x < 0 ];
	//[ self set_rotation:-dir_to_angle(movedir)];
//    GameBase* game = [GameBase get_game];

}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint loc = [touch locationInView: touch.view];
    if ( m_id == 0 )
    {
        if ( loc.x > 1024/2 || loc.y > 768 / 2  )
            return FALSE;
    }
    if ( m_id == 1 )
    {
        if ( loc.x > 1024/2 || loc.y < 768 / 2  )
            return FALSE;
    }
    if ( m_id == 2 )
    {
        if ( loc.x < 1024/2 || loc.y > 768 / 2  )
            return FALSE;
    }
    if ( m_id == 3 )
    {
        if ( loc.x < 1024/2 || loc.y < 768 / 2  )
            return FALSE;
    }
	m_touch_begin_pos = [touch locationInView: touch.view];
	return TRUE;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint pt = [touch locationInView: touch.view];
	
	movedir = ccpSub(pt, m_touch_begin_pos);
	float len = ccpLength(movedir);
	movedir = ccpNormalize(movedir);
	if ( len > m_dir_controller_length );
		m_touch_begin_pos =  ccpAdd( m_touch_begin_pos, ccpMult(movedir, len - m_dir_controller_length));
	
	movedir.y *= -1;
	
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}


-(void) set_id:(int) id
{
    m_id = id;
}
-(void) dealloc
{
	[m_alive_counter_label release];
	[[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
	[super dealloc];
}
@end

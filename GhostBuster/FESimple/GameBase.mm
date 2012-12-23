//
//  GameBase.m
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import "GameBase.h"

#import "GameScene.h"
#import "Level.h"
#include "Box2D.h"
#import "CDAudioManager.h"
#import "World.h"
#import "SpriteDefManager.h"
#ifdef __CC_PLATFORM_IOS
#import "IOSInputDevice.h"
#endif

GameBase* g_game = NULL;

@implementation GameBase

@synthesize  m_world = m_world_;
@synthesize  m_scene = m_scene_;        // the view
@synthesize  m_DBG_loop_stat = m_DBG_loop_stat_;
@synthesize  m_level = m_level_;


float		m_current_time;
NSDate*     m_start_time;
InputDeviceBase* g_input_device = NULL;

+(void) set_game: (GameBase*) game
{
	g_game = game;
}

+(GameBase*) get_game
{
	return g_game;
}



-(void) update:(float) delta_time
{
    NSDate* now = [NSDate date ];
    m_current_time = [ now timeIntervalSinceDate:m_start_time ];
	
	// [scorelable draw];
}

+(float) current_time
{
    return m_current_time;
}
-(void) request_reset
{
    m_will_reset = true;
}
-(void) cleanup_world
{
    if ( m_world_ != NULL )
    {
        [ m_world_ cleanup];// remove all objects in world
    }
    if ( m_scene_ != NULL )
    {
        [ m_scene_.m_layer removeAllChildrenWithCleanup:TRUE ];
        [ m_scene_.m_UIlayer removeAllChildrenWithCleanup:TRUE ];
		[ m_scene_.m_BGLayer1 removeAllChildrenWithCleanup:TRUE ];
		[ m_scene_.m_BGLayer2 removeAllChildrenWithCleanup:TRUE ];
		
    }
}
-(void) cleanup
{
	   
    [ self cleanup_world ];

}

-(void) reset
{
    [ self cleanup ];
    [ self init_game ];
}

-(BOOL) need_reset
{
    return m_will_reset;
}

-(void) reseted
{
    m_will_reset = false;
}


+(float) get_ptm_ratio
{
    return 32;
}

-(void) init_game
{
	
    [ self cleanup];
    srandom(time(NULL));
    [ self reseted ];
}


-(int) init_default //just need call onec per run
{
    m_start_time = [ NSDate date ];
    [ m_start_time retain ];
//    m_sprites = [[NSMutableArray alloc] init];
    m_scene_ = [ GameScene node ];
    m_world_ = [ World new ];
    self.m_scene.m_layer.m_world = m_world_;
	
    
    //audio
    [ CDAudioManager sharedManager];

	
    return 0;
}

-(GameObjBase*) add_game_obj_by_classname:(NSString*) classname spawn_params:(NSDictionary*) spawn_params
{
    Class c = NSClassFromString(classname);
    assert( [c isSubclassOfClass:[GameObjBase class]]);
	
    GameObjBase* object = [ [ c alloc] init_with_spawn_params:spawn_params];
    //if ( [object isKindOfClass:[SpriteBase class]] )
    //{
    //    [ ((SpriteBase*)object) init_with_spawn_params:spawn_params ];
    //}
    [m_world_ add_gameobj:object];
    return object;
}
+(InputDeviceBase*) get_input_device
{

	if ( g_input_device == NULL )
	{
#ifdef __CC_PLATFORM_IOS
		g_input_device = [IOSInputDevice new];
#endif
	}
	return g_input_device;
}

-(bool) is_editor
{
    return false;
}
@end

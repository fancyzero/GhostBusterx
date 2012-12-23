//
//  GameBase.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import <Foundation/Foundation.h>
@class GameObjBase;
@class World;
@class GameScene;
@class InputDeviceBase;
@class LevelBase;
@interface GameBase : NSObject
{
	bool			m_will_reset;
	//NSMutableArray* _sprites;
	GameScene*		m_scene_;			//the visible world
	World*			m_world_;			// the logic world
	int				m_DBG_loop_stat_;
	LevelBase*		m_level_;

}
-(int) init_default;
-(void) reset;
-(BOOL) need_reset;
-(void) reseted;
-(void) init_game;
-(void) update : (float) delta_time;
-(bool) is_editor;
-(void) cleanup_world;
+(float) current_time;
+(float) get_ptm_ratio;
+(void) set_game: (GameBase*) game;
+(GameBase*)	get_game;
+(InputDeviceBase*) get_input_device;


-(GameObjBase*) add_game_obj_by_classname:(NSString*) classname spawn_params:(NSDictionary*) spawn_params;


-(void) cleanup;

@property   (nonatomic, assign)		GameScene*  m_scene;			//the visible world
@property   (nonatomic, assign)		World*      m_world;			// the logic world
@property   (nonatomic, assign)		int         m_DBG_loop_stat;
@property	(nonatomic, assign)		LevelBase*	m_level;
@end



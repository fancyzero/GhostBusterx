//
//  GBLevel.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import "Level.h"
#import <vector>
@class CCTMXTiledMap;
@class PhysicsSprite;
@class LevelCollider;
@class CCLabelTTF;
class b2body;
struct Grid
{
	int x;
	int y;
};
@interface GBLevel : LevelBase
{
	@public
	float			m_spawn_cross_time;
	int game_state;
    float           m_restart_after;
    CCTMXTiledMap	*m_tiled_map;
    float           m_game_end_time;
	std::vector<NSArray*> m_walkableAdjacent_cache;
	std::vector<CGPoint> m_walkable_tiles;
	LevelCollider*		m_level_collider;
	float			m_cross_spawn_rate;

	
}

@property (nonatomic,assign) int m_grid_size;

-(bool) pending_restart;
//path finding...
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;
-(bool) isWallAtPositionCoord:(CGPoint) pt :(float) radius;
-(bool) isWallAtTileCoord:(CGPoint) pt;
-(bool) isValidTileCoord:(CGPoint) pt;
- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;
- (NSArray *)get_walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;
-(bool) raycast:(CGPoint) start :(CGPoint) end;
-(void) reset;
-(CGSize) get_mapsize;
-(b2Body*) setup_level_collider:(PhysicsSprite*) collider_spr;
-(bool) is_coin:(CGPoint) pos;
-(void) spawn_coin:(CGPoint) pos;
-(void) remove_coin:(CGPoint) pos;
@end

//
//  LevelCollider.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-22.
//
//

#import "SpriteBase.h"
@class GBLevel;
@interface LevelCollider : SpriteBase
-(void) init_by_level:(GBLevel* )level;

@end

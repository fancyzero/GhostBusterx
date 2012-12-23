//
//  PlayerBase.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import <Foundation/Foundation.h>


@class LevelBase;
@class GameBase;
@interface PlayerBase : NSObject

-(id) init_with_game: (GameBase*) level;

@end

//
//  GBGame.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import <Foundation/Foundation.h>
#import "GameBase.h"
@interface GBGame : GameBase
{
	NSDictionary* global_config;
}
-(void) init_game;
-(id) get_config_value:(NSString*) key;
@end

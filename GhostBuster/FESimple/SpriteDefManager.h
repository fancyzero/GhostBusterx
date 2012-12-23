//
//  SpriteDefManager.h
//  ShotAndRun3
//
//  Created by Fancy Zero on 12-6-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBase.h"
@interface SpriteDefManager : NSObject
+(void) add_sprite_def: ( struct sprite_def*) def :(NSString*) name;
+(void) add_sprite_component_def: ( struct sprite_component_def*) def :(NSString*) name;
+(struct sprite_def*) load_sprite_def : (NSString*) filename;
+(struct sprite_component_def*) load_sprite_component_def : (NSString*) filename;
+(void) load_sprite_def_database:(NSString*) filename;
+(void) load_sprite_component_def_database:(NSString*) filename;
@end

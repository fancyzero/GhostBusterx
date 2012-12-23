//
//  Controller.h
//  GhostBuster
//
//  Created by Zero Fancy on 12-12-15.
//
//

#import <Foundation/Foundation.h>
#import "ControllerBase.h"
#include <vector>
@interface Controller : NSObject
-(void) on_touch_move:(CGPoint) pos :(CGPoint) prev_pos;
-(BOOL) on_touch_begin: (CGPoint) pos;
-(void) on_touch_end:(CGPoint) pos;
-(void) on_touches_began: ( const std::vector<touch_info>& )touches;
-(void) on_touches_ended: ( const std::vector<touch_info>& )touches;
@end

//
//  ControllerBase.h
//  ShotAndRun4
//
//  Created by Zero Fancy on 12-11-20.
//
//

#import <Foundation/Foundation.h>
#include <vector>
struct touch_info
{
    CGPoint touch_pos;
};
@interface ControllerBase : NSObject
-(void) on_touch_move:(CGPoint) pos :(CGPoint) prev_pos;
-(BOOL) on_touch_begin: (CGPoint) pos;
-(void) on_touch_end:(CGPoint) pos;
-(void) on_touches_began: ( const std::vector<touch_info>& )touches;
-(void) on_touches_ended: ( const std::vector<touch_info>& )touches;
@end

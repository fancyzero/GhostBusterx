//
//  GameScene.m
//  testproj1
//
//  Created by Fancy Zero on 12-3-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "GameViewLayer.h"

@implementation GameScene

@synthesize m_layer;
@synthesize m_UIlayer;
@synthesize m_BGLayer1 = m_BGLayer1_;
@synthesize m_BGLayer2 = m_BGLayer2_;
@synthesize m_ed_viewoffset = m_ed_viewoffset_;
+(id) node
{
    GameScene* ret;
	
    ret = [super node ] ;
	ret.m_ed_viewoffset = ccp(0,0);
    if ( ret )
    {
        ret.m_layer = [[[GameViewLayer alloc ] init]autorelease] ;
		[ret.m_layer setAnchorPoint:ccp(0,0)];
        ret.m_UIlayer = [ GameUILayer node];
		ret.m_BGLayer1 = [ GameLayer node];
		ret.m_BGLayer1.m_move_scale = 0.5;
		ret.m_BGLayer2 = [ GameLayer node];

		[ ret addChild: ret.m_layer z:3];
        [ ret.m_layer scheduleUpdate ];
		
        [ret addChild: ret.m_UIlayer z:100];
		[ret.m_UIlayer setAnchorPoint:ccp(0,0)];
		[ret addChild: ret.m_BGLayer1 z:1];
		[ret.m_BGLayer1 setAnchorPoint:ccp(0,0)];
		[ret addChild: ret.m_BGLayer2 z:0];
		[ret.m_BGLayer2 setAnchorPoint:ccp(0,0)];

    }
    return ret;
}

@end

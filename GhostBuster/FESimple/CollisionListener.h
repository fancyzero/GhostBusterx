//
//  CollisionListener.h
//  shotandrun
//
//  Created by Fancy Zero on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef shotandrun_CollisionListener_h
#define shotandrun_CollisionListener_h

struct Collision 
{
    class b2Fixture *fixtureA;
    class b2Fixture *fixtureB;
    bool operator==(const Collision& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class CollisionListener : public b2ContactListener 
{
    
public:

    
    CollisionListener();
    ~CollisionListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
public:
    std::vector<Collision> m_collisions;
    
};

#endif

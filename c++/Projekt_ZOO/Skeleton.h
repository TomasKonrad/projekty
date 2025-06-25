//
// Created by rysst on 17.01.2025.
//

#ifndef SKELETON_H
#define SKELETON_H

class Skeleton{
protected:
    Skeleton(){};
public:
    virtual int getUtok()=0;
    static Skeleton* getSkeleton(int level);
    virtual ~Skeleton() {};
    virtual bool isWalkable() const { return true; };
};



#endif //SKELETON_H

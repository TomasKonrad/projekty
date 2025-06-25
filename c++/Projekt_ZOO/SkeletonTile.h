//
// Created by rysst on 11.12.2024.
//

#ifndef SKELETONTILE_H
#define SKELETONTILE_H
#include "Skeleton.h"
#include "Tile.h"


class SkeletonTile : public Tile {
    private:
    Skeleton* m_skeleton;
public:
    SkeletonTile();
    SkeletonTile(Skeleton* skeleton);
    virtual~SkeletonTile() {};
    virtual bool isWalkable() const {return true;}
    void drawTile() const override;
    Skeleton* getSkeleton();
};



#endif //SKELETONTILE_H

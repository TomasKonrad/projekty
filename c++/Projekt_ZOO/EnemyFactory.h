//
// Created by rysst on 17.01.2025.
//

#ifndef ENEMYFACTORY_H
#define ENEMYFACTORY_H
#include "BossTile.h"
#include "GoblinTile.h"
#include "SkeletonTile.h"


class EnemyFactory {
public:
    static GoblinTile* createGoblin(int level);
    static SkeletonTile* createSkeleton(int level);
    static BossTile* createBoss(int level);
};



#endif //ENEMYFACTORY_H

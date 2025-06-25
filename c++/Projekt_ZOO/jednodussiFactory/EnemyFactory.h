//
// Created by rysst on 17.01.2025.
//

#ifndef ENEMYFACTORY_H
#define ENEMYFACTORY_H
#include "Goblin.h"
#include "Skeleton.h"

class EnemyFactory {
public:
    static Goblin* createGoblin(int level);
    static Skeleton* createSkeleton(int level);
};



#endif //ENEMYFACTORY_H

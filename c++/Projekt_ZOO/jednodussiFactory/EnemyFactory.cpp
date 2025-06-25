//
// Created by rysst on 17.01.2025.
//

#include "EnemyFactory.h"

#include "GoblinLite.h"
#include "GoblinPro.h"

Goblin *EnemyFactory::createGoblin(int level) {
    return Goblin::getGoblin(level);
}

Skeleton *EnemyFactory::createSkeleton(int level) {
    return Skeleton::getSkeleton(level);
}




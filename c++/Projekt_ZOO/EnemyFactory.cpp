//
// Created by rysst on 17.01.2025.
//

#include "EnemyFactory.h"

#include "GoblinLite.h"
#include "GoblinPro.h"

GoblinTile* EnemyFactory::createGoblin(int level) {
    Goblin* goblin = Goblin::getGoblin(level);
    return new GoblinTile(goblin);
}

SkeletonTile *EnemyFactory::createSkeleton(int level) {
    Skeleton* skeleton = Skeleton::getSkeleton(level);
    return new SkeletonTile(skeleton);
}

BossTile *EnemyFactory::createBoss(int level) {
    Boss* boss= Boss::getBoss(level);
    return new BossTile(boss);
}





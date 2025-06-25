//
// Created by rysst on 11.12.2024.
//

#include "SkeletonTile.h"
#include <iostream>

SkeletonTile::SkeletonTile() {
}

SkeletonTile::SkeletonTile(Skeleton *skeleton) {
    m_skeleton = skeleton;
}

void SkeletonTile::drawTile() const {
    std::cout << " S ";
}

Skeleton *SkeletonTile::getSkeleton() {
    return m_skeleton;
}



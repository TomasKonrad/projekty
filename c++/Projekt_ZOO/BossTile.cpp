//
// Created by rysst on 18.01.2025.
//

#include "BossTile.h"
#include <iostream>


BossTile::BossTile() {
}

BossTile::BossTile(Boss* boss) {
    m_boss = boss;
}

void BossTile::drawTile() const {
    std::cout << " Bs ";
}

Boss *BossTile::getBoss() {
    return m_boss;
}

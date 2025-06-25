//
// Created by rysst on 11.12.2024.
//

#include "GoblinTile.h"
#include <iostream>

GoblinTile::GoblinTile() {
}

GoblinTile::GoblinTile(Goblin* goblin) {
    m_goblin = goblin;
}

/*
int GoblinTile::getDamage() {
    return m_damage;
}

int GoblinTile::getStrenght() {
    return m_strenght;
}
*/

void GoblinTile::drawTile() const {
    std::cout << " G ";
}

Goblin *GoblinTile::getGoblin() {
    return m_goblin;
}

//
// Created by rysst on 11.12.2024.
//

#include "SwordTile.h"
#include "Sword.h"
#include <iostream>
#include "Inventory.h"

SwordTile::SwordTile() {
}

void SwordTile::drawTile() const {
    std::cout << " / ";
}

void SwordTile::addSword(Inventory& inventory) {
    Sword* sword = new Sword("Essential_Sword");
    inventory.addItem(sword);
    std::cout << "You picked up Armor"<< std::endl;
}

// metoda v testování
Sword* SwordTile::getSword() {
    return m_sword;
}
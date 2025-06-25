//
// Created by rysst on 11.12.2024.
//
#include "ArmorTile.h"
#include <iostream>
#include "Inventory.h"

ArmorTile::ArmorTile() {
}

void ArmorTile::drawTile() const {
    std::cout << " H ";
}

void ArmorTile::addArmor(Inventory &inventory) {
    Armor *armor = new Armor("Essential_Armor");
    inventory.addItem(armor);
    std::cout << "You picked up a armor"<< std::endl;
}

Armor *ArmorTile::getArmor() {
    return m_armor;
}

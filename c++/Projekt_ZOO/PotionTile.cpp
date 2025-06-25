//
// Created by rysst on 18.01.2025.
//

#include "PotionTile.h"

#include <iostream>

#include "Inventory.h"
#include "Potion.h"

PotionTile::PotionTile() {
}

void PotionTile::drawTile() const {
    std::cout << " U ";
}

void PotionTile::addPotion(Inventory &inventory) {
    Potion *potion = new Potion("Potion for health");
    inventory.addItem(potion);
    std::cout << "You picked up a armor"<< std::endl;
}

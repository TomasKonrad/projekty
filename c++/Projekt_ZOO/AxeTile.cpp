//
// Created by rysst on 11.12.2024.
//

#include "AxeTile.h"
#include "Axe.h"
#include <iostream>
#include "Inventory.h"


AxeTile::AxeTile() {
}

void AxeTile::drawTile() const {
    std::cout << " 1 ";
}

void addAxe(Inventory& inventory) {
    Axe*  axe = new Axe("Axe");
    inventory.addItem(axe);
    std::cout << "You picked up: "<< std::endl;
}

Axe *AxeTile::getAxe() {
    return m_axe;
}



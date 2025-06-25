//
// Created by danie on 1/21/2025.
//

#include "Sidebar.h"

#include <iostream>

Sidebar::Sidebar(Player* player, Inventory* inventory)
    : player(player), inventory(inventory) {}

void Sidebar::drawSidebar() const {
    std::cout << "----- Player Stats -----" << std::endl;
    std::cout << "Health: " << player->getHealth() << std::endl;
    std::cout << "Damage: " << player->getDamage() << std::endl;
    std::cout << "Defense: " << player->getDefense() << std::endl;
    std::cout << std::endl;

    std::cout << "----- Inventory -----" << std::endl;
    std::vector<Items*> items = inventory->getItems();
    for (Items* item : items) {
        if (item) {
            std::cout << "- " << item->getName() << std::endl;
        }
    }
    std::cout << std::endl;
}
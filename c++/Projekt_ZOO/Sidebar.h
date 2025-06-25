//
// Created by danie on 1/21/2025.
//

#ifndef SIDEBAR_H
#define SIDEBAR_H

#include <iostream>
#include <vector>
#include <string>
#include "Player.h"
#include "Inventory.h"

class Sidebar {
private:
    Player* player;
    Inventory* inventory;

public:
    Sidebar(Player* player, Inventory* inventory);
    void drawSidebar() const;
};

#endif // SIDEBAR_H

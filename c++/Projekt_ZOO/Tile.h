//
// Created by danie on 11/26/2024.
//

#ifndef TILE_H
#define TILE_H
#include <string>
#include "Inventory.h"
using namespace std;


class Tile {
public:
    virtual ~Tile() {}
    virtual bool isWalkable() const { return true; }

    virtual void drawTile() const = 0;
    //virtual void mineItems(Inventory* target);
};



#endif //TILE_H

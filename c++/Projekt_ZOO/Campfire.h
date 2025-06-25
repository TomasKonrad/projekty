//
// Created by Daniel Jánek on 03.12.2024.
//

#ifndef PROJEKT_ZOO_CAMPFIRE_H
#define PROJEKT_ZOO_CAMPFIRE_H


#include "Tile.h"

class Campfire : public Tile {
public:
    Campfire();
    virtual ~Campfire() {}
    virtual bool isWalkable() const { return true; }

    void drawTile() const override;
};


#endif //PROJEKT_ZOO_CAMPFIRE_H

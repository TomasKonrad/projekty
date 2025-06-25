//
// Created by rysst on 18.01.2025.
//

#ifndef POTIONTILE_H
#define POTIONTILE_H
#include "Tile.h"


class PotionTile : public Tile {
public:
    PotionTile();
    virtual ~PotionTile() {};
    virtual bool isWalkable() const { return true; }
    void addPotion(Inventory& inventory);
    void drawTile() const override;
};



#endif //POTIONTILE_H

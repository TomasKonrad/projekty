//
// Created by rysst on 11.12.2024.
//

#ifndef SWORDTILE_H
#define SWORDTILE_H
#include "Tile.h"
#include "Sword.h"



class SwordTile : public Tile{
private:
    Sword* m_sword;
public:
    SwordTile();
    virtual ~SwordTile() {}
    virtual bool isWalkable() const { return true; }
    void addSword(Inventory& inventory);
    void drawTile() const override;
    Sword* getSword();
};



#endif //SWORDTILE_H

//
// Created by rysst on 18.01.2025.
//

#ifndef BOSSTILE_H
#define BOSSTILE_H
#include "Tile.h"
#include "Boss.h"


class BossTile : public Tile {
private:
    Boss* m_boss;
public:
    BossTile();
    BossTile(Boss* boss);
    virtual~BossTile() {}
    virtual bool isWalkable() const {return true;}
    void drawTile() const override;
    Boss* getBoss();
};



#endif //BOSSTILE_H

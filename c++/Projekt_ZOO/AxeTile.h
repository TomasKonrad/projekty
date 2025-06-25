//
// Created by rysst on 11.12.2024.
//

#ifndef AXETILE_H
#define AXETILE_H
#include "Axe.h"
#include "Tile.h"


class AxeTile : public Tile {
private:
    Axe* m_axe;
public:
    AxeTile();
    virtual ~AxeTile() {}
    virtual bool isWalkable() const { return true; }
    void addAxe(Inventory& inventory);
    void drawTile() const override;
    Axe* getAxe();
};



#endif //AXETILE_H

//
// Created by danie on 11/26/2024.
//

#ifndef BUSH_H
#define BUSH_H
#include "Tile.h"
using namespace std;


class Bush : public Tile {
public:
    Bush();
    virtual ~Bush() {}
    virtual bool isWalkable() const {return true;}
    void mine();
    void drawTile() const override;
};



#endif //BUSH_H

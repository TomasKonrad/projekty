//
// Created by danie on 11/30/2024.
//

#ifndef WALL_H
#define WALL_H
#include "Tile.h"


class Wall : public Tile{

    public:
    Wall();
    Wall(int type);
    virtual ~Wall() {}
    virtual bool isWalkable() const { return false; }

    void drawTile() const override;

};



#endif //WALL_H

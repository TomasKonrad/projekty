//
// Created by danie on 11/26/2024.
//

#ifndef GROUND_H
#define GROUND_H
#include "Tile.h"
#include "Tile.h"

class Ground : public Tile {
    int m_ground;

public:
    Ground();
    Ground(int type);
    virtual ~Ground() {}
    virtual bool isWalkable() const { return true; }

    void drawTile() const override;
};



#endif //GROUND_H

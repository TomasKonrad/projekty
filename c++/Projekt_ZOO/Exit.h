//
// Created by danie on 12/10/2024.
//

#ifndef EXIT_H
#define EXIT_H
#include "Map.h"
#include "Tile.h"




class Exit : public Tile {
private:
    int targetMapId;
    int targetX, targetY;

public:

    Exit(int mapId, int x, int y);


    bool isWalkable() const override;


    void drawTile() const override;


    int getTargetMapId() const;


    std::pair<int, int> getTargetPosition() const;


    Map* switchMap() const;
};

#endif // EXIT_H


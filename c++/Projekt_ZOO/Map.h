#ifndef MAP_H
#define MAP_H

#include <vector>

#include "Tile.h"

class Map {
private:
    std::vector<std::vector<Tile*>> m_map;
    unsigned int m_width;
    unsigned int m_height;

public:
    Map(unsigned int width, unsigned int height);
    ~Map();
    bool isTileWalkable(int x, int y) const;
    void drawMap() const;
    void setTile(unsigned int row, unsigned int column, Tile* tile);
    Tile* getTile(int row, int col) const;
    unsigned int getWidth() const { return m_width; }
    unsigned int getHeight() const { return m_height; }


};

#endif // MAP_H

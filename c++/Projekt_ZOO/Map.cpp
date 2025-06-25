#include "Map.h"
#include "Ground.h"
#include "Tile.h"
#include <iostream>
#include <stdexcept>

#include "Exit.h"


using namespace std;


Map::Map(unsigned int width, unsigned int height)
    : m_width(width), m_height(height) {
    for (unsigned int i = 0; i < height; ++i) {
        vector<Tile*> row;
        for (unsigned int j = 0; j < width; ++j) {
            row.push_back(new Ground());
        }
        m_map.push_back(row);
    }
}

bool Map::isTileWalkable(int x, int y) const {
    if (x < 0 || y < 0 || x >= m_width || y >= m_height) {
        return false;
    }
    return m_map[y][x]->isWalkable();
}


Map::~Map() {
    for (auto& row : m_map) {
        for (auto& tile : row) {
            delete tile;
        }
    }
}


void Map::drawMap() const {
    system("cls");

    for (const auto& row : m_map) {
        for (const auto& tile : row) {

            if (dynamic_cast<const Exit*>(tile)) {
                std::cout << "Exit Tile at position\n";
            }
            tile->drawTile();
        }
        std::cout << std::endl;
    }
}


void Map::setTile(unsigned int row, unsigned int column, Tile* tile) {
    if (row >= m_height || column >= m_width) {
        throw out_of_range("Invalid row or column index for setTile.");
    }

    delete m_map[row][column];
    m_map[row][column] = tile;

}

Tile* Map::getTile(int row, int column) const {
    if (row >= 0 && row < m_height && column >= 0 && column < m_width) {
        return m_map[row][column];
    }
    return nullptr;
}


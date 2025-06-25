//
// Created by danie on 12/10/2024.
//

#include "Exit.h"
#include <iostream>
#include "MapCreator.h"

Exit::Exit(int mapId, int x, int y)
    : targetMapId(mapId), targetX(x), targetY(y) {}

bool Exit::isWalkable() const {

    return true;
}

void Exit::drawTile() const {

    std::cout << " E ";

}


int Exit::getTargetMapId() const {
    return targetMapId;
}


std::pair<int, int> Exit::getTargetPosition() const {
    return {targetX, targetY};
}


Map* Exit::switchMap() const {
    std::cout << "Switching to map ID: " << targetMapId << std::endl;
    std::string filename = "C:/Users/rysst/zoo_zs2024_xjanek/Projekt_ZOO/maps/map"s + std::to_string(targetMapId) + ".txt";
    std::cout << "Attempting to load map from file: " << filename << std::endl;

    try {

        Map* newMap = MapCreator::createMap(targetMapId);
        return newMap;
    } catch (const std::exception& e) {
        std::cerr << "Error: Could not load map with ID " << targetMapId << ". "
                  << e.what() << std::endl;
        return nullptr;
    }
}


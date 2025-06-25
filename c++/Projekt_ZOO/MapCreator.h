//
// Created by danie on 11/30/2024.
//

#ifndef MAPCREATOR_H
#define MAPCREATOR_H
#include "Map.h"
#include "MapCreator.h"
#include <vector>

using namespace std;


class MapCreator {
public:

    static Map* createMap(int mapId);

private:

    static Map* loadMapFromFile(const std::string& filename);
};




#endif //MAPCREATOR_H

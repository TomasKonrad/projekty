//
// Created by danie on 11/30/2024.
//

#include "MapCreator.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include "ArmorTile.h"
#include "AxeTile.h"
#include "SwordTile.h"
#include "Bush.h"
#include "Map.h"
#include "Wall.h"
#include "Campfire.h"
#include "Exit.h"
#include "BossTile.h"
#include "GoblinTile.h"
#include "Ground.h"
using namespace std;

Map* MapCreator::createMap(int mapId) {
    std::string filename = "C:/Users/rysst/zoo_zs2024_xjanek/Projekt_ZOO/maps/map" + std::to_string(mapId) + ".txt";  // ID je součástí názvu souboru

    try {
        return loadMapFromFile(filename);
    } catch (const std::exception& e) {
        std::cerr << "Error cteni mapy podle ID " << mapId << ": " << e.what() << std::endl;
        return nullptr;
    }
}

Map* MapCreator::loadMapFromFile(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("Mapa nesla otevrit: " + filename);
    }

    int width, height;
    std::string line;


    if (std::getline(file, line)) {
        size_t spacePos = line.find(' ');
        if (spacePos == std::string::npos) {
            throw std::runtime_error("Nespravne dimenze mapy.");
        }
        width = std::stoi(line.substr(0, spacePos));
        height = std::stoi(line.substr(spacePos + 1));
    } else {
        throw std::runtime_error("Failed to read map dimensions from file.");
    }

    Map* map = new Map(width, height);


    while (std::getline(file, line)) {
        size_t delimPos1 = line.find(',');
        size_t delimPos2 = line.find(',', delimPos1 + 1);
        size_t delimPos3 = line.find(',', delimPos2 + 1);

        if (delimPos1 == std::string::npos || delimPos2 == std::string::npos) {
            std::cerr << "Preskakuji nespravny kod: " << line << std::endl;
            continue;
        }


        int x = std::stoi(line.substr(0, delimPos1));
        int y = std::stoi(line.substr(delimPos1 + 1, delimPos2 - delimPos1 - 1));
        std::string type = line.substr(delimPos2 + 1, delimPos3 - delimPos2 - 1);

        if (type == "Bush") {
            map->setTile(x, y, new Bush());
        } else if (type == "Wall") {
            map->setTile(x, y, new Wall());
        } else if (type == "GoblinTile") {
            map->setTile(x, y, new GoblinTile());
        } else if (type == "SwordTile") {
            map->setTile(x, y, new SwordTile());
        } else if (type == "BossTile") {
            map->setTile(x, y, new BossTile());
        } else if (type == "Campfire") {
            map->setTile(x, y, new Campfire());
        } else if (type == "Exit") {
            if (delimPos3 != std::string::npos) {
                // Pokud existují další parametry (mapId, targetX, targetY)
                size_t delimPos4 = line.find(',', delimPos3 + 1);
                size_t delimPos5 = line.find(',', delimPos4 + 1);

                int targetMapId = std::stoi(line.substr(delimPos3 + 1, delimPos4 - delimPos3 - 1));
                int targetX = std::stoi(line.substr(delimPos4 + 1, delimPos5 - delimPos4 - 1));
                int targetY = std::stoi(line.substr(delimPos5 + 1));

                map->setTile(x, y, new Exit(targetMapId, targetX, targetY));
            } else {
                std::cerr << "Error: nespravny Exit format na: " << x << "," << y << std::endl;
            }
        }
    }

    file.close();
    return map;
}




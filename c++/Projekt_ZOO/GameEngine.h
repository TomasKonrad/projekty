//
// Created by danie on 12/13/2024.
//

#ifndef GAMEENGINE_H
#define GAMEENGINE_H
#include "Map.h"
#include "Player.h"
#include "Inventory.h"
#include "EnemyFactory.h"


class GameEngine {
public:
    GameEngine();
    ~GameEngine();
    void runGame();

private:
    Map* map;
    Player* player;
    Inventory* inventory;
    EnemyFactory* enemyfactory;
    void startGame();
    void createEnemyes();
    void gameInfo();
};

#endif //GAMEENGINE_H

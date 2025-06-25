//
// Created by danie on 12/7/2024.
//

#ifndef PLAYER_H
#define PLAYER_H


#include "Map.h"

class Player {
private:
    int x, y;
    Map* map;
    int m_health;
    int m_damage;
    int m_defense;
    Inventory* inventory;

public:
    Player(Map* gameMap, int startX, int startY);
    void move(char key);
    void drawPlayer() const;
    int getX() const { return x; }
    int getY() const { return y; }
    void interactWithTile();
    //void interactWithGoblinTile();
    //void interactWithSkeletonTile();
    //void interactWithBossTile();
    int getHealth() const { return m_health; }
    int getDamage() const { return m_damage; }
    int getDefense() const { return m_defense; }

    void updateStats();
    void addItemToInventory(Items* item);

};

#endif // PLAYER_H





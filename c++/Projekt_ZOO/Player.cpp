//
// Created by danie on 12/7/2024.
//

#include "Player.h"
#include <iostream>

#include "Bush.h"
#include "Exit.h"
#include "Ground.h"
#include "Inventory.h"
#include "Sword.h"
#include "SwordTile.h"
#include "Armor.h"
#include "ArmorTile.h"
#include "Axe.h"
#include "AxeTile.h"
#include "GoblinTile.h"

using namespace std;

Player::Player(Map* gameMap, int startX, int startY)
    : map(gameMap), x(startX), y(startY), m_health(100), m_damage(5), m_defense(0) {
    inventory = new Inventory();
    if (!map->isTileWalkable(x, y)) {
        throw invalid_argument("Starting position is not walkable!");
    }
}

void Player::move(char key) {
    int newX = x, newY = y;

    switch (key) {
        case 'w': newY--; break;
        case 'a': newX--; break;
        case 's': newY++; break;
        case 'd': newX++; break;
        case 'e': interactWithTile(); return;
        case 'i': inventory->printInventory();
        default:
            return;
    }


    if (newX < 0 || newY < 0 || newX >= map->getWidth() || newY >= map->getHeight()) {
        cout << "Cannot move outside the map!" << endl;
        return;
    }

    if (map->isTileWalkable(newX, newY)) {
        x = newX;
        y = newY;

        // Výpis pro debugování
        cout << "Player moved to (" << y << ", " << x << ")." << endl;

        Tile* currentTile = map->getTile(y, x);
        if (auto* exit = dynamic_cast<Exit*>(currentTile)) {
            cout << "Found Exit at (" << y << ", " << x << "). Traveling to a new map..." << endl;

            Map* newMap = exit->switchMap();
            if (newMap) {
                delete map;
                map = newMap;
                auto targetPos = exit->getTargetPosition();  // Získání cílové pozice
                x = targetPos.first;
                y = targetPos.second;
                cout << "Arrived at new map at (" << y << ", " << x << ")." << endl;
            } else {
                cerr << "Error: Failed to load the new map!" << endl;
            }
        }
    } else {
        cout << "Cannot move to (" << newY << ", " << newX << ") - Tile not walkable." << endl;
    }
}

void Player::drawPlayer() const {

    //map->drawMap();


    cout << "Player is at (" << y << ", " << x << ")." << endl;
    for (int i = 0; i < map->getHeight(); ++i) {
        for (int j = 0; j < map->getWidth(); ++j) {
            if (i == y && j == x) {
                cout << " P ";
            } else {
                map->getTile(i, j)->drawTile();
            }
        }
        cout << endl;
    }
}

//tato metoda by se mohla využít i pro přidávání do inventáře a nahrazení políčka groundem

void Player::interactWithTile() {
    Tile* currentTile = map->getTile(y, x);
    if (auto* bush = dynamic_cast<Bush*>(currentTile)) {
        bush->mine();
        map->setTile(y, x, new Ground());
    } else {
        cout << "There is nothing to mine here." << endl;
    }

    if (auto* swordTile = dynamic_cast<SwordTile*>(currentTile)) {
        Sword* newSword = swordTile->getSword();
        inventory->addItem(newSword);
        map->setTile(y, x, new Ground());
    } else {
        cout << "There is nothing to bring." << endl;
    }

    if (auto* axeTile = dynamic_cast<AxeTile*>(currentTile)) {
        Axe* newAxe = axeTile->getAxe();
        inventory->addItem(newAxe);
        map->setTile(y, x, new Ground());
    } else {
        cout << "There is nothing to bring." << endl;
    }

    if (auto* armorTile = dynamic_cast<ArmorTile*>(currentTile)) {
        Armor* newArmor = armorTile->getArmor();
        inventory->addItem(newArmor);
        map->setTile(y, x, new Ground());
    } else {
        cout << "There is nothing to bring." << endl;
    }

    /*po použití této metody program spadne
     *if (auto* swordTile = dynamic_cast<SwordTile*>(currentTile)) {
        auto* inventory = dynamic_cast<Inventory*>(currentTile);
        Sword* newSword = swordTile->getSword();
        inventory->addItem(newSword);
        map->setTile(y, x, new Ground());
    } else {
        cout << "There is nothing to bring." << endl;
    }*/
}

void Player::addItemToInventory(Items *item) {
    inventory->addItem(item);
    updateStats();
}


void Player::updateStats() {
    m_health = 100;
    m_damage = 5;
    m_defense = 0;

    std::vector<Items*> items = inventory->getItems();
    for (Items* item : items) {
        if (auto* sword = dynamic_cast<Sword*>(item)) {
            m_damage += sword->getDamage();
        }
        if (auto armor = dynamic_cast<Armor*>(item)) {
            m_defense += armor->getDefence();
        }
        /*    Takto by mohol fungovat heal potion ked bude pridany ako objekt
         *if (auto* potion = dynamic_cast<Potion*>(item)) {
            m_health += potion->getHP();
        }
        */
    }

}

/*void Player::interactWithGoblinTile() {
    Tile* currentTile = map->getTile(y, x);

    if (auto* goblin = dynamic_cast<Goblin*>(currentTile)) {
        if(goblin->jeNazivu()){
          goblin->getGoblin();
          goblin->dostanPoskozeni(Player* player);
          goblin->dejPoskozeni(Player* player);
          }else{
           std::cout<<"Goblin byl poražen!"<<std::endl;
            map->setTile(y, x, new Ground());
          }
            //toto až v případě. kdy goblin bude mít 0 životů
            //map->setTile(y, x, new Ground());
    }

}*/




//
// Created by danie on 12/13/2024.
//

#include "GameEngine.h"
#include <conio.h>
#include <iostream>
#include <bits/error_constants.h>

#include "MapCreator.h"
#include "Inventory.h"
#include "Sidebar.h"

GameEngine::GameEngine() : map(nullptr), player(nullptr) {}

GameEngine::~GameEngine() {
    delete map;
}
Sidebar* sidebar = nullptr;

void GameEngine::runGame() {
    startGame();

    while (true) {
        if (_kbhit()) {
            char key = _getch();
            if (key == 'q') break;
            player->move(key);
            player->drawPlayer();
            sidebar->drawSidebar();
        }
    }
}

void GameEngine::startGame() {
    int mapId = 1; // Výchozí mapa

    try {
        map = MapCreator::createMap(mapId);
    } catch (const std::exception& e) {
        std::cerr << "Error loading map: " << e.what() << std::endl;
        return;
    }

    player = new Player(map, 1, 1); // Výchozí pozice hráče
    inventory = new Inventory();
    sidebar = new Sidebar(player, inventory);

    // Vykreslení celé mapy
    map->drawMap();

    // Vykreslení hráče
    player->drawPlayer();
    //sidebar->drawSidebar();

    inventory = new Inventory();
    enemyfactory = new EnemyFactory();
    createEnemyes();
    gameInfo();

}

void GameEngine::createEnemyes() {
    int level;
    std::cout<<"Zadejte level (1 = easy; 2 = hard)"<<endl;
    std::cin>>level;

        if(level == 1 or level == 2) {
            enemyfactory->createGoblin(level);
            enemyfactory->createSkeleton(level);
            enemyfactory->createBoss(level);
            BossTile* boss = enemyfactory->createBoss(level);
            std::cout << "Byly vytvořeni nepřátelé " << level <<"levelu."<<std::endl;
        }else {
            std::cerr<<"Neplatný parametr. Zvol(1 nebo 2)"<<std::endl;
            createEnemyes();
        }
}

void GameEngine::gameInfo() {
    std::cout<<"----- Dulezite informace o hre -----"<<std::endl;
    std::cout<<std::endl;

    std::cout<<" -- Ovladani -- "<<endl;
    std::cout<<"znak 'q' = ukonceni hry"<<std::endl;
    std::cout<<"znak 'e' = pridani do inventare"<<std::endl;
    std::cout<<"znak 'w' = pohyb nahoru"<<std::endl;
    std::cout<<"znak 'a' = pohyb doleva"<<std::endl;
    std::cout<<"znak 's' = pohyb dolu"<<std::endl;
    std::cout<<"znak 'd' = pohyb doprava"<<std::endl;
    std::cout<<std::endl;

    std::cout<<" -- Symboly na mape -- "<<endl;
    std::cout<<std::endl;
    std::cout<<"symbol 'E' = exit z mapy (prechod na dalsi)"<<std::endl;
    std::cout<<"symbol 'P' = Player"<<std::endl;
    std::cout<<"symbol 'U' = Potion"<<std::endl;
    std::cout<<"symbol 'H' = Armor"<<std::endl;
    std::cout<<"symbol '1' = Axe"<<std::endl;
    std::cout<<"symbol '/' = Sword"<<std::endl;
    std::cout<<"symbol '@' = Ker"<<std::endl;
    std::cout<<"symbol 'C' = Campfire"<<std::endl;
    std::cout<<"symbol '#' = Walls"<<std::endl;
    std::cout<<std::endl;

    std::cout<<" -- Enemies -- "<<std::endl;
    std::cout<<std::endl;
    std::cout<<"symbol 'Bs' = Boss"<<std::endl;
    std::cout<<"symbol 'G' = Goblin"<<std::endl;
    std::cout<<"symbol 'S' = Goblin"<<std::endl;
    std::cout<<std::endl;
    std::cout<<std::endl;
    
    std::cout<<"Klikni na LIBOVOLNOU KLAVESU pro pokracovani do hry"<<std::endl;
}


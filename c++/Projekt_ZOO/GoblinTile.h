//
// Created by rysst on 11.12.2024.
//

#ifndef GOBLINTILE_H
#define GOBLINTILE_H
#include "Goblin.h"
#include "Tile.h"


class GoblinTile : public Tile{
private:
    //int m_damage;
    //int m_strenght;
    Goblin* m_goblin;
public:
    GoblinTile();
    GoblinTile(Goblin* goblin);
    virtual~GoblinTile() {}
    virtual bool isWalkable() const {return true;}
    //int getDamage();
    //int getStrenght();
    void drawTile() const override;
    Goblin* getGoblin();
};



#endif //GOBLINTILE_H

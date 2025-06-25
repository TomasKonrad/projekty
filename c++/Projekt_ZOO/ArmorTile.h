//
// Created by rysst on 11.12.2024.
//

#ifndef ARMORTILE_H
#define ARMORTILE_H
#include "Armor.h"
#include "Tile.h"


class ArmorTile : public Tile{
private:
    //std::string m_name;
    Armor* m_armor;
public:
    ArmorTile();
    virtual ~ArmorTile() {}
    virtual bool isWalkable() const { return true; }
    void addArmor(Inventory& inventory);
    void drawTile() const override;
    //std::string getName();
    Armor* getArmor();
};



#endif //ARMORTILE_H

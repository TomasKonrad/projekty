//
// Created by rysst on 07.12.2024.
//

#ifndef ARMOR_H
#define ARMOR_H
#include "Items.h"

class Armor :public Items {
private:
    void setDamage();
public:
    Armor(std::string name);
    int getDamage() override;
    int getDefence() override;
    std::string getName() override;
};


#endif //ARMOR_H

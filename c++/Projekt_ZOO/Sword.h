//
// Created by rysst on 26.11.2024.
//

#ifndef SWORD_H
#define SWORD_H
#include "Items.h"
#include "Inventory.h"

class Sword : public Items {
private:
    void setDefence();
public:
    Sword(std::string name);
    int getDamage() override;
    int getDefence() override;
    std::string getName() override;
    //void mineItems(Inventory* target);
};



#endif //SWORD_H

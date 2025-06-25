//
// Created by rysst on 18.01.2025.
//

#ifndef POTION_H
#define POTION_H
#include "Items.h"


class Potion :public Items {
private:
    int m_pridaniZdravi;
public:
    Potion(std::string name);
    int getDamage() override;
    int getDefence() override;
    int getPridaniZdravi();
    std::string getName() override;
};



#endif //POTION_H

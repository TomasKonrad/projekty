//
// Created by rysst on 07.12.2024.
//

#ifndef AXE_H
#define AXE_H
#include "Items.h"

class Axe : public Items{
private:
    void setDefence();
public:
    Axe(std::string name);
    int getDamage() override;
    int getDefence() override;
    std::string getName();
};



#endif //AXE_H

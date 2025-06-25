//
// Created by rysst on 26.11.2024.
//

#ifndef INVENTORY_H
#define INVENTORY_H
#include <vector>
#include "Items.h"
//varianta ze cvika

class Inventory {
private:
    //int m_gold;
    //int m_diamond;
    std::vector<Items*> m_items;
public:
    //Inventory(int gold=0, int diamond=0);
    Inventory();
    //void addGold(int gold);
    //void addDiamond(int diamond);
    void addItem(Items* item);
    std::string getItemName();
    void printInventory();
    std::vector<Items*> getItems() const;
};


#endif //INVENTORY_H

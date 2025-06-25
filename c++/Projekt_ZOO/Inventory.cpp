//
// Created by rysst on 26.11.2024.
//

#include "Inventory.h"
#include "Player.h"//kdyžtak pryč
#include <iostream>

/*Inventory::Inventory(int gold, int diamond) {
    m_gold = gold;
    m_diamond=diamond;
}

void Inventory::addGold(int gold) {
    m_gold += gold;
}
void Inventory::addDiamond(int diamond) {
    m_diamond+=diamond;
}
*/

Inventory::Inventory() {
}

void Inventory::addItem(Items* item) {
    m_items.push_back(item);
    std::cout<<"Item added"<<std::endl;

}

void Inventory::printInventory() {
   /* std::cout <<"---Inventory---"<<std::endl
    << "Gold: " << m_gold <<
        ", Wheat: "<<m_diamond<< std::endl;
    */
    //výpis itemů z vektoru
    std::cout <<"---Vypis inventareInventar---"<<std::endl;
    std::cout<<std::endl;
    for(int i=0; i< m_items.size(); i++) {
        if(m_items.at(i)) {
            std::cout<<m_items.at(i)->getName() <<std::endl;
        }
    }
}

std::vector<Items*> Inventory::getItems() const {
    return m_items;
}


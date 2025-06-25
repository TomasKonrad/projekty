//
// Created by rysst on 26.11.2024.
//

#ifndef ITEMS_H
#define ITEMS_H
#include <string>


class Items {
protected:
    std::string m_name;
    int m_damage;
    int m_defence;
public:
    Items();
    virtual int getDamage()=0;
    virtual int getDefence()=0;
    virtual std::string getName()=0;
};



#endif //ITEMS_H

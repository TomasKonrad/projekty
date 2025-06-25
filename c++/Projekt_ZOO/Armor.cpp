//
// Created by rysst on 07.12.2024.
//

#include "Armor.h"

Armor::Armor(std::string name) {
    m_name = name;
    m_defence=5;
    setDamage();
}


int Armor::getDamage() {
    return m_damage;
}

int Armor::getDefence() {
    return m_defence;
}

void Armor::setDamage() {
    m_damage = 0;
}

std::string Armor::getName() {
    return m_name;
}

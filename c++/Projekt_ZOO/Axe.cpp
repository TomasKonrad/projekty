//
// Created by rysst on 07.12.2024.
//

#include "Axe.h"
#include "Items.h"

Axe::Axe(std::string name): Items() {
    m_name=name;
    m_damage=7;
    setDefence();
}


int Axe::getDamage() {
    return m_damage;
}

int Axe::getDefence() {
    return m_defence;
}

void Axe::setDefence() {
    m_defence = 0;
}

std::string Axe::getName() {
    return m_name;
}

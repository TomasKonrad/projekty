//
// Created by rysst on 26.11.2024.
//

#include "Sword.h"
#include "Items.h"

Sword::Sword(std::string name): Items() {
    m_name=name;
    m_damage=10;
    setDefence();
}

int Sword::getDamage() {
    return m_damage;
}

int Sword::getDefence() {
    return m_defence;
}

void Sword::setDefence() {
    m_defence = 0;
}

std::string Sword::getName() {
    return m_name;
}

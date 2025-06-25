//
// Created by rysst on 18.01.2025.
//

#include "Potion.h"
Potion::Potion(std::string name) {
    m_name = name;
    m_defence=0;
    m_damage=0;
    m_pridaniZdravi=3;
}

int Potion::getDamage() {
    return m_damage;
}

int Potion::getDefence() {
    return m_defence;
}

int Potion::getPridaniZdravi() {
    return m_pridaniZdravi;
}

std::string Potion::getName() {
    return m_name;
}
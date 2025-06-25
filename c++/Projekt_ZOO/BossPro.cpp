//
// Created by rysst on 18.01.2025.
//

#include "BossPro.h"
BossPro::BossPro(int sila, int zdravi) {
    m_sila=sila;
    m_zdravi=zdravi;
}

int BossPro::getUtok() {
    return m_sila;
}

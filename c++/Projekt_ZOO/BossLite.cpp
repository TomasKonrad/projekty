//
// Created by rysst on 18.01.2025.
//

#include "BossLite.h"

BossLite::BossLite(int sila, int zdravi) {
    m_sila=sila;
    m_zdravi=zdravi;
}

int BossLite::getUtok() {
    return m_sila;
}
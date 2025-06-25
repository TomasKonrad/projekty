//
// Created by rysst on 17.01.2025.
//

#include "GoblinPro.h"
GoblinPro::GoblinPro(int sila, int zdravi) {
    m_sila=sila;
    m_zdravi=zdravi;
}

int GoblinPro::getUtok() {
    return m_sila;
}

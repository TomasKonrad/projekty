//
// Created by rysst on 17.01.2025.
//

#include "GoblinLite.h"

GoblinLite::GoblinLite(int sila, int zdravi) {
    m_sila=sila;
    m_zdravi=zdravi;
}

int GoblinLite::getUtok() {
    return m_sila;
}


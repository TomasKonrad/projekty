//
// Created by rysst on 17.01.2025.
//

#include "GoblinLite.h"

#include <iostream>

GoblinLite::GoblinLite(int sila, int zdravi) {
    m_sila=sila;
    m_zdravi=zdravi;
}

int GoblinLite::getUtok() {
    return m_sila;
}

int GoblinLite::getZdravi() {
    return m_zdravi;
}

bool GoblinLite::jeNazivu() {
    if(m_zdravi>0) {
        return m_zdravi;
    }
    return false;
}

int GoblinLite::DostanPoskozeni(Player* player) {
    m_zdravi-=player->getDamage();
    jeNazivu();
    /*if (m_zdravi<=0) {
        std::cout<<"Enemy dostal poškozeni. Zbývá mu: "<<m_zdravi<<std::endl;
    }*/
    return m_zdravi;
}

int GoblinLite::DejPoskozeni(Player* player) {
    int hracZivot=player->getHealth();
    return hracZivot-m_sila;
}

//
// Created by rysst on 17.01.2025.
//

#include "SkeletonPro.h"

SkeletonPro::SkeletonPro(int sila, int zdravi) {
    m_sila = sila;
    m_zdravi = zdravi;
}

int SkeletonPro::getUtok() {
    return m_sila;
}


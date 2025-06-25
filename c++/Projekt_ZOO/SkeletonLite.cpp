//
// Created by rysst on 17.01.2025.
//

#include "SkeletonLite.h"

SkeletonLite::SkeletonLite(int sila, int zdravi){
    m_sila=sila;
    m_zdravi=zdravi;
}

int SkeletonLite::getUtok() {
    return m_sila;
}
//
// Created by rysst on 17.01.2025.
//

#ifndef SKELETONPRO_H
#define SKELETONPRO_H
#include "Skeleton.h"


class SkeletonPro :public Skeleton {
    protected:
        int m_sila;
    int m_zdravi;
public:
    SkeletonPro(int sila, int zdravi);
    int getUtok();
};



#endif //SKELETONPRO_H

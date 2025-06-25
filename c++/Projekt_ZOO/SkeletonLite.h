//
// Created by rysst on 17.01.2025.
//

#ifndef SKELETONLITE_H
#define SKELETONLITE_H
#include "Skeleton.h"


class SkeletonLite : public Skeleton{
protected:
    int m_sila;
    int m_zdravi;
public:
    SkeletonLite(int sila, int zdravi);
    int getUtok();
};



#endif //SKELETONLITE_H

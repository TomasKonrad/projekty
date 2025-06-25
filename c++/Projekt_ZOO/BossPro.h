//
// Created by rysst on 18.01.2025.
//

#ifndef BOSSPRO_H
#define BOSSPRO_H
#include "Boss.h"


class BossPro : public Boss{
protected:
    int m_sila;
    int m_zdravi;
public:
    BossPro(int sila, int zdravi);
    int getUtok();
};



#endif //BOSSPRO_H

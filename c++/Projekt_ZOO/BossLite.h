//
// Created by rysst on 18.01.2025.
//

#ifndef BOSSLITE_H
#define BOSSLITE_H
#include "Boss.h"


class BossLite : public Boss{
protected:
    int m_sila;
    int m_zdravi;
public:
    BossLite(int sila, int zdravi);
    int getUtok();
};



#endif //BOSSLITE_H

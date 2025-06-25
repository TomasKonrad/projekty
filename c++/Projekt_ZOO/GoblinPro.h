//
// Created by rysst on 17.01.2025.
//

#ifndef GOBLINPRO_H
#define GOBLINPRO_H
#include "Goblin.h"


class GoblinPro:public Goblin {
protected:
    int m_sila;
    int m_zdravi;
public:
    GoblinPro(int sila, int zdravi);
    int getUtok();
};



#endif //GOBLINPRO_H

//
// Created by rysst on 17.01.2025.
//

#ifndef GOBLINLITE_H
#define GOBLINLITE_H
#include "Goblin.h"
#include "Player.h"


class GoblinLite : public Goblin{
protected:
    int m_sila;
    int m_zdravi;
public:
    GoblinLite(int sila, int zdravi);
    int getUtok();
    int DostanPoskozeni(Player* player);
    int DejPoskozeni(Player* player);
    bool jeNazivu();
    int getZdravi();

};



#endif //GOBLINLITE_H

//
// Created by rysst on 17.01.2025.
//

#include "Goblin.h"
#include <iostream>
#include "GoblinLite.h"
#include "GoblinPro.h"

Goblin *Goblin::getGoblin(int level) {
    switch (level) {
        case 1:
            return new GoblinLite(5,2);
        case 2:
            return new GoblinPro(10,20);
        default:
            std::cerr << "Tato úroveň je nedostupná"<< std::endl;
        return nullptr;
    }
}

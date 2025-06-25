//
// Created by rysst on 18.01.2025.
//

#include "Boss.h"

#include <iostream>

#include "BossLite.h"
#include "BossPro.h"

Boss *Boss::getBoss(int level) {
    switch (level) {
        case 1:
            return new BossLite(5,30);
        case 2:
            return new BossPro(7,40);
        default:
            std::cerr << "Tato úroveň je nedostupná"<< std::endl;
        return nullptr;
    }
}

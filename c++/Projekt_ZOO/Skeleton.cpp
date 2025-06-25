//
// Created by rysst on 17.01.2025.
//

#include "Skeleton.h"
#include <iostream>
#include "SkeletonLite.h"
#include "SkeletonPro.h"

Skeleton *Skeleton::getSkeleton(int level) {
    switch (level) {
        case 1:
            return new SkeletonLite(3,10);
        case 2:
            return new SkeletonPro(4,12);
        default:
            std::cerr << "Tato úroveň je nedostupná"<< std::endl;
        return nullptr;
    }
}

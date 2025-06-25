#include <iostream>

#include "Goblin.h"

/*************************************************
 *Zatím idea, main někam přehodit
 *
 *
 ************************************************/
int main()
{
    int rozhodnuti;

    std::cout << "Zvol si obtiznost: ";
    std::cin >> rozhodnuti;

    Goblin* nepritel = nullptr;

    nepritel = Goblin::getGoblin(rozhodnuti);

    std::cout << "Sila: " << nepritel->getUtok() << std::endl;

    delete nepritel;
    return 0;
}

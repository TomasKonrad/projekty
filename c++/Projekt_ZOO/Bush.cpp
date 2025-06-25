//
// Created by danie on 11/26/2024.
//

#include "Bush.h"
#include "Map.h"
#include "Ground.h"
using namespace std;
#include <iostream>

Bush::Bush() {

}


void Bush::drawTile() const {
    cout << " @ ";
}
void Bush::mine() {
    cout << "You mined the bush!" << endl;
}
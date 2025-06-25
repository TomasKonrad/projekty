//
// Created by danie on 11/26/2024.
//

#include "Ground.h"
#include <iostream>
using namespace std;


Ground::Ground() : m_ground(0) {}


Ground::Ground(int type) : m_ground(type) {}


void Ground::drawTile() const {
    cout << " . ";
}

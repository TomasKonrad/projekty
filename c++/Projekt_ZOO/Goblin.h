//
// Created by rysst on 17.01.2025.
//

#ifndef GOBLIN_H
#define GOBLIN_H

class Goblin {
protected:
    Goblin(){};
public:
    virtual int getUtok()=0;
    static Goblin* getGoblin(int level);
    virtual ~Goblin() {};
    virtual bool isWalkable() const { return true; };
};



#endif //GOBLIN_H

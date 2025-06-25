//
// Created by rysst on 18.01.2025.
//

#ifndef BOSS_H
#define BOSS_H



class Boss {
    protected:
        Boss(){};
    public:
        virtual int getUtok()=0;
        static Boss* getBoss(int level);
        virtual ~Boss() {};
        virtual bool isWalkable() const { return true; };
};



#endif //BOSS_H

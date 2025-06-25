cmake_minimum_required(VERSION 3.29)
project(jednodussiFactory)

set(CMAKE_CXX_STANDARD 20)

add_executable(jednodussiFactory main.cpp
        Goblin.cpp
        Goblin.h
        GoblinLite.cpp
        GoblinLite.h
        GoblinPro.cpp
        GoblinPro.h
        Skeleton.cpp
        Skeleton.h
        SkeletonLite.cpp
        SkeletonLite.h
        SkeletonPro.cpp
        SkeletonPro.h
        EnemyFactory.cpp
        EnemyFactory.h)

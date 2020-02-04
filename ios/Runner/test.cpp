//
//  test.cpp
//  Runner
//
//  Created by Apple on 2019/7/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#include "test.hpp"
using namespace std;

class test{
public:
    void getWeight(){
        cout<<"Object C与C++混合编程。体重为："<<weight<<"kg";
        printf("调用C＋＋语言。getWeight");
    }
    void setWeight(int x){
        weight = x;
        printf("调用C＋＋语言。setWeigth");
    }
    
private:
    int weight;
};

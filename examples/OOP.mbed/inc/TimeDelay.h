/*
 * TimeDelay.h
 *
 *  Created on: Jul 17, 2014
 *      Author: iztok
 */

#ifndef TIMEDELAY_H_
#define TIMEDELAY_H_

#include <queue>
#include <list>
#include <random>

using namespace std;

class TimeDelay {
private:
	list<int> l;
	queue<int,list<int>> q;

	mt19937 prng;
	uniform_int_distribution<int> dist;

public:
	TimeDelay();
	~TimeDelay();
	int get();
};

#endif /* TIMEDELAY_H_ */

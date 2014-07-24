/*
 * Counter.cpp
 *
 *  Created on: Jul 17, 2014
 *      Author: iztok
 */

#include "TimeDelay.h"

using namespace std;

TimeDelay::TimeDelay() {
	l = list<int> {0x3FFFFF, 0x7FFFFF, 0xBFFFFF, 0xFFFFFF};
	q = queue<int,list<int>> (l);
	dist = uniform_int_distribution<int> (0x1,0xFFFFFF);
}

TimeDelay::~TimeDelay() {
}

int TimeDelay::get() {
	int retVal=q.front();
	q.pop();
	q.push(dist(prng));
	return retVal;
}

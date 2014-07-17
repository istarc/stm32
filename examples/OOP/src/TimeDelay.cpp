/*
 * Counter.cpp
 *
 *  Created on: Jul 17, 2014
 *      Author: iztok
 */

#include "TimeDelay.h"

using namespace std;

TimeDelay::TimeDelay() {
	q1.push(0x3FFFFF);
	q1.push(0x7FFFFF);
	q1.push(0xBFFFFF);
	q1.push(0xFFFFFF);
}

TimeDelay::~TimeDelay() {
}

int TimeDelay::get() {

	int retVal=q1.front();
	q1.pop();
	q1.push(retVal);

	return retVal;
}

/*
 * Counter.cpp
 *
 *  Created on: Jul 17, 2014
 *      Author: iztok
 */

#include "Counter.h"

Counter::Counter(int cnt) {
	this->cnt=cnt;
}

Counter::~Counter() {
}

int Counter::get() {
	this->cnt--;
	return this->cnt;
}

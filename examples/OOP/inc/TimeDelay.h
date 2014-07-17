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

using namespace std;

class TimeDelay {
private:
	queue<int, std::list<int>> q1;

public:
	TimeDelay();
	~TimeDelay();
	int get();
};

#endif /* TIMEDELAY_H_ */

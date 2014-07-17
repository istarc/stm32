/*
 * Counter.h
 *
 *  Created on: Jul 17, 2014
 *      Author: iztok
 */

#ifndef COUNTER_H_
#define COUNTER_H_

class Counter {
private:
	unsigned int cnt;
public:
	Counter(int);
	~Counter();
	int get();
};

#endif /* COUNTER_H_ */

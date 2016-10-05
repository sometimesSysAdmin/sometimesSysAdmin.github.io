/*	Jamie Harvey
	harvey.jamie.j@gmail.com
	sometimesSysAdmin.github.io

*/

#include <iostream>
#include <string>

#ifndef LIST_H
#define LIST_H

using namespace std;

struct CElem {
  string info;
  int id;
  CElem *next;
  CElem *back;
};

class CList {
 public:
  void disp();
  //Displays the list starting with what *current is pointing to
  void shiftRight();
  //Shifts *current to the right
  void shiftLeft();
  //Shifts *current to the left
  void addElement(const string, const int);
  //Adds an element at the "end" prior to current
  void removeElement(int);
  //Removes element specified by int as ID
  bool isEmpty() const;
  //Checks if count == 0
  int length() const;
  //Returns count
  CList();
  ~CList();
 private: 
  CElem *current;
  int count;
};

#endif

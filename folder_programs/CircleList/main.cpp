/*	Jamie Harvey
	harvey.jamie.j@gmail.com
	sometimesSysAdmin.github.io

	Input:	User enters a choice for menu option. If adding an element
		user inputs the element's information (string)
	Output: List displayed at start of each iteration. Menu options and
		various prompts according to menu selection.
	Description:
		This program creates a circular list.  The beginning of the list is
		identified by int* current.  At each iteration the program will
		display the list and then menu.  The user can:
		1: Add an element - will prompt for new elements info (string) and assigns
			a unique ID (integer).
		2: Remove element - will prompt for ID (integer) of element to remove.
		3: Shift right - The new start of the list will be the element that
			directly follows the original starting element.
		4: Shift right - The new start of the list will be the element that
			preceeded that original starting element (the original end).
		5: Exit the program.

*/


#include "list.h"
#include <iostream>

using namespace std;

int main() {
  int menuChoice; //Holds user input for menu
  string enteredData;
  int removeID;
  int nextID = 1;
  CList c1;

  while (menuChoice != 5) {
  menuStart: //Used for invalid menu exception to restart loop
    cout << "List:" << endl;
    c1.disp();
    cout << "1.Add element" << endl << "2.Remove element" << endl << "3.Shift Right"
	 << endl << "4.Shift left" << endl << "5.Exit" << endl << "Enter choice: ";
    try {
      cin >> menuChoice;
      if (!cin || menuChoice < 1 || menuChoice > 5)
	throw menuChoice;
    }
    catch(...) {
      cout << "Please enter a valid menu choice." << endl << endl;
      cin.clear();
      cin.ignore(100, '\n');
      goto menuStart;
    }
    if (menuChoice == 1) {
      cout << "Enter data: ";
      cin >> enteredData;
      c1.addElement(enteredData, nextID);
      nextID++;
    }
    else if (menuChoice == 2) {
      cout << "Enter ID to delete: ";
    removeStart: //Used for invalid ID exception to restart remove
      try {
	cin >> removeID;
	if (!cin)
	  throw removeID;
	c1.removeElement(removeID);
      }
      catch(...) {
	while (!cin) {
	  cout << "Please enter a valid ID number: ";
	  cin.clear();
	  cin.ignore(100, '\n');
	  goto removeStart;
	}
      }
    }
    else if (menuChoice == 3) {
      c1.shiftRight();
    }
    else if (menuChoice == 4) {
      c1.shiftLeft();
    }
    else
      return 0;

    cout << endl << endl;
  }
}

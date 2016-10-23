#ifndef mydllist_h
#define mydllist_h

#include <stdlib.h>

//Doubly linked list implementation
struct Node {
  char data[20];
  struct Node* next;
  struct Node* prev;
};

struct Node* sentinel; //global pointer to the sentinel node
struct Node* head;
struct Node* tail;

struct Node* MakeSentinel();

struct Node* GetNewNode(char *x);

void InsertAtHead(char *x);

void PrintHead();

void DeleteEntry(struct Node* del);

#endif

     
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "cgen.h"
#include"lambdalib.h"
typedef struct Address Address;
struct Address{
 

StringType street;

int number;

StringType city;

void (*setAddress) (struct Address *self, StringType s, int n, StringType c);
void (*printAddress) (struct Address *self);

}; 
void printAddress (struct Address *self){
write("Address: %s %d, %s\n", self->street, self->number, self->city);
}; 
void setAddress (struct Address *self, StringType s, int n, StringType c){
self->street = s;
self->number = n;
self->city = c;
};
typedef struct Person Person;
struct Person{
 

StringType firstName, lastName;

StringType email;

int phone;

Address address;

void (*setPerson) (struct Person *self, StringType fn, StringType ln, StringType email, int phone, Address addr);
void (*printPersonInfo) (struct Person *self);

}; 
void printPersonInfo (struct Person *self){
write("%s %s, email: %s phone: %d\n", self->firstName, self->lastName, self->email, self->phone);
self->address.printAddress(&self->address);
}; 
void setPerson (struct Person *self, StringType fn, StringType ln, StringType email, int phone, Address addr){
self->firstName = fn;
self->lastName = ln;
self->email = email;
self->phone = phone;
self->address = addr;
};
typedef struct Book Book;
struct Book{
 

StringType title, isbn;

Person author;

int numOfCopies;

double price;

void (*setBook) (struct Book *self, StringType t, Person a, int numOfCopies, double price);
void (*printBook) (struct Book *self);

}; 
void printBook (struct Book *self){
write("Title: %s\n", self->title);
writeStr("Author:");
self->author.printPersonInfo(&self->author);
write("Price:%f\n", self->price);
write("Number of available copies: %d\n", self->numOfCopies);
}; 
void setBook (struct Book *self, StringType t, Person a, int numOfCopies, double price){
self->title = t;
self->author = a;
self->numOfCopies = numOfCopies;
self->price = price;
};
typedef struct Order Order;
struct Order{
 

int orderNum;

Book book;

int quantity;

Address shippingAddress;

int delivered;

void (*setOrder) (struct Order *self, int orNum, Book b, int q, Address sh, int del);
void (*printOrder) (struct Order *self);

}; 
void printOrder (struct Order *self){
write("Order number: %d\nBook:\n", self->orderNum);
self->book.printBook(&self->book);
write("Quantity: %d\nShipping address: \n", self->quantity);
self->shippingAddress.printAddress(&self->shippingAddress);
write("Delivered: %d\n", self->delivered);
}; 
void setOrder (struct Order *self, int orNum, Book b, int q, Address sh, int del){
self->orderNum = orNum;
self->book = b;
self->quantity = q;
self->shippingAddress = sh;
self->delivered = del;
};
typedef struct Bookstore Bookstore;
struct Bookstore{
 

StringType name;

Book listOfBooks[100];

int numOfBooks;

Order listOfOrders[100];

int numOfOrders;

void (*putOrder) (struct Bookstore *self, Order o);
void (*addBook) (struct Bookstore *self, Book b);
void (*printBookStoreBooks) (struct Bookstore *self);
double (*calculateTotalOrdersIncome) (struct Bookstore *self);

}; 
double calculateTotalOrdersIncome (struct Bookstore *self){
double total;
total = 0;
for (int i = 0; i < self->numOfOrders; i ++) {
if (self->listOfOrders[i].delivered) {
total = total + self->listOfOrders[i].quantity * self->listOfOrders[i].book.price;
}

}

return total;

}; 
void printBookStoreBooks (struct Bookstore *self){
for (int i = 0; i < self->numOfBooks; i ++) {
self->listOfBooks[i].printBook(&self->listOfBooks[i]);
}

}; 
void addBook (struct Bookstore *self, Book b){
self->listOfBooks[self->numOfBooks] = b;
self->numOfBooks += 1;
}; 
void putOrder (struct Bookstore *self, Order o){
self->listOfOrders[self->numOfOrders] = o;
self->numOfOrders += 1;
};
int orderId;
Address createAddress (StringType s, int n, StringType c) {
Address a = { .printAddress = printAddress, .setAddress = setAddress };
a.setAddress(&a, s, n, c);
return a;

}
Person createPerson (StringType fn, StringType ln, StringType email, int phone, Address addr) {
Person p = { .printPersonInfo = printPersonInfo, .setPerson = setPerson };
p.setPerson(&p, fn, ln, email, phone, addr);
return p;

}
Book createBook (StringType t, Person a, int numOfCopies, double price) {
Book b = { .printBook = printBook, .setBook = setBook };
b.setBook(&b, t, a, numOfCopies, price);
return b;

}
Order createOrder (int orNum, Book b, int q, Address sh, int del) {
Order ord = { .printOrder = printOrder, .setOrder = setOrder };
ord.setOrder(&ord, orNum, b, q, sh, del);
return ord;

}
Bookstore createBookstore (StringType n) {
Bookstore bs = { .calculateTotalOrdersIncome = calculateTotalOrdersIncome, .printBookStoreBooks = printBookStoreBooks, .addBook = addBook, .putOrder = putOrder };
bs.name = n;
bs.numOfBooks = 0;
bs.numOfOrders = 0;
return bs;

}
int main ( ) {
orderId = 0;
Address a, a1 = { .printAddress = printAddress, .setAddress = setAddress };
a = createAddress("Stadiou", 10, "Stadiou");
Person author = { .printPersonInfo = printPersonInfo, .setPerson = setPerson };
author = createPerson("Christos", "Papadimitriou", "cpap@gmail.com", 12345, a);
Book b = { .printBook = printBook, .setBook = setBook };
b = createBook("Computation Theory", author, 34.3, 100);
Bookstore bs = { .calculateTotalOrdersIncome = calculateTotalOrdersIncome, .printBookStoreBooks = printBookStoreBooks, .addBook = addBook, .putOrder = putOrder };
bs = createBookstore("Papasotiriou");
bs.addBook(&bs, b);
a = createAddress("Wall Street", 10, "NY");
author = createPerson("Dennis", "Richie", "richie@gmail.com", 54321, a);
b = createBook("C Programming", author, 10.3, 100);
bs.addBook(&bs, b);
bs.printBookStoreBooks(&bs);
Order ord = { .printOrder = printOrder, .setOrder = setOrder };
ord = createOrder(orderId, b, 2, a, 0);
orderId += 1;
ord.printOrder(&ord);
bs.putOrder(&bs, ord);
write("Bookstore orders income: %.2f\n", bs.calculateTotalOrdersIncome(&bs));
};
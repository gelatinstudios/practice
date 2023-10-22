#include <stdio.h>
int x ;
int y ;
int z ;
int q ;
int r ;
int n ;
int f ;
int a ;
int b ;
int w ;
int f ;
int g ;
void divide ();
void fact ();
void gcd ();
void multiply ();
void divide () {
{
r  = x;
q  = 0;
w  = y;
while ((w) <= (r)) {
w  = (2) * (w);
}
while ((w) > (y)) {
{
q  = (2) * (q);
w  = (w) / (2);
if ((w) <= (r)) {
{
r  = (r) - (w);
q  = (q) + (1);
}
}
}
}
}
}
void fact () {
{
if ((n) > (1)) {
{
f  = (n) * (f);
n  = (n) - (1);
fact ();
}
}
}
}
void gcd () {
{
f  = x;
g  = y;
while ((f) != (g)) {
{
if ((f) < (g)) {
g  = (g) - (f);
}
if ((g) < (f)) {
f  = (f) - (g);
}
}
}
z  = f;
}
}
void multiply () {
{
a  = x;
b  = y;
z  = 0;
while ((b) > (0)) {
{
if ((b) % 2 != 0) {
z  = (z) + (a);
}
a  = (2) * (a);
b  = (b) / (2);
}
}
}
}
int main(void) {
{
scanf("%d", &x);
scanf("%d", &y);
multiply ();
printf("%d\n", z);
scanf("%d", &x);
scanf("%d", &y);
divide ();
printf("%d\n", q);
printf("%d\n", r);
scanf("%d", &x);
scanf("%d", &y);
gcd ();
printf("%d\n", z);
scanf("%d", &n);
f  = 1;
fact ();
printf("%d\n", f);
}
}

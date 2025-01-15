
# FDM - Functional Document Maker


The functions in FDM are really more like macros, tbh FDM, standing for Functional Document Maker (creative, I know), is a document maker that is more of a programming language than any other document fomat. You can create and call functions. There is a standard library of functions, defined in `src/standard.nim`.


# Available functions


Note that you must import std in order to access all of the following functions.


## Built-in functions

signature|explaination|
|-|-|
table(<rows>)|Structure for a table make a table like follows table(row(a,b,c),row(d,e,f)).|
row(<items>)|used in table() as described above|
list(<items>)|returns the arguments organized as a list|
if(<true or false>){<content>}|checks if the argument provided is true, and if it is, it'll return <content>|
else{<content>}|Returns <content> if the above if statement and elif statements are false.|
sum(<items>)|Adds numbers within and returns the value. returns ERROR if the inner values aren't numbers. Must be integers.|
sub{<content>}|Returns the subscripted <content>|
sup{<content>}|Returns the superscripted <content>|
text{<content>}|Returns <content> formatted in a way such that all characters will be displayed as-is in the output|
frac(<numerator>, <denominator>)|Returns a formatted fraction of the two values. Especially useful when compiling to latex|


## standard library functions

signature|explaination|
|-|-|
link(<URL>){<content>}|Makes a link to <URL> with <content> as the text|


## Standard Library Variables

### Math Symbols

mult|×|
|-|-|
plusmin|±|
sqrt|√|
noteq|≠|
approxeq|≈|
theta|θ|


# Compiling/installing


To compile, run nimble build -d:release -d:ssl, and copy the newly created "fdm" file to your $PATH.


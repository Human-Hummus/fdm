
# FDM - Functional Document Maker


The functions in FDM are really more like macros, tbh FDM, standing for Functional Document Maker (creative, I know), is a document maker that is more of a programming language than any other document fomat. You can create and call functions. There is a standard library of functions, defined in `src/standard.nim`.


# Available functions

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
frac(<numerator>, <denominator>)|Returns a formatted fraction of the two values.|


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

(<sup>1</sup>/<sup>2</sup>)
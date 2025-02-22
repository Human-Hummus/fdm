
# FDM - Functional Document Maker


THIS DOCUMENTATION IS GROSSLY INCOMPLETE



The functions in FDM are really more like macros, tbh FDM, standing for Functional Document Maker (creative, I know), is a document maker that is more of a programming language than any other document fomat. You can create and call functions. There is a standard library of functions, defined in `src/standard.nim`.


# Creating/Calling Functions


To create a function you first type the "func" keyword, then the function's name, then, in parenthesis, the function's arguments' names seperated by commas. Then, the contents of the function surrounded by curly brackets. This is quite similar to how functions are defined in some programming languages, like C and Python. It would look like this:

`func my\_function(a,b){"I recieved argument a as " $a "!"}`


Calling functions is identical to how you'd call functions in Python, C, and countless other programming languages: the name of the function followed by the arguments, sperated by commas, surrounded by parenthesis. This is followed by the function "input" surrounded by curly brackets. To call the above function, you could write, for example:

`my\_function(This\_is\_a, this\_is\_b){the\_input}`


For more examples, review the standard library, found in [src/standard.nim](https://github.com/Human-Hummus/fdm/blob/main/src/standard.nim)


# Variables

## TODO

# CLI args



# Available functions


Note that you must import std in order to access all of the following functions.


## Built-in functions

signature|explaination|
|-|-|
table(\<rows\>)|Structure for a table make a table like follows table(row(a,b,c),row(d,e,f)).|
row(\<items\>)|used in table() as described above|
list(\<items\>)|returns the arguments organized as a list|
if(\<true or false\>){\<content\>}|checks if the argument provided is true, and if it is, it'll return \<content\>|
else{\<content\>}|Returns \<content\> if the above if statement and elif statements are false.|
sum(\<items\>)|Adds numbers within and returns the value. returns ERROR if the inner values aren't numbers. Must be integers.|
text{\<content\>}|Returns \<content\> formatted in a way such that all characters will be displayed as-is in the output|
frac(\<numerator\>, \<denominator\>)|Returns a formatted fraction of the two values. Especially useful when compiling to latex, as HTML and Markdown don't support recursive fractions.|


## standard library functions

signature|explaination|
|-|-|
sub{\<content\>}|Returns the subscripted \<content\>|
sup{\<content\>}|Returns the superscripted \<content\>|
link(\<URL\>){\<content\>}|Makes a link to \<URL\> with \<content\> as the text|


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


To compile, run the following command and copy the newly created "fdm" file to your $PATH.

`nimble build -d:release -d:ssl`
OR
`nimble build -d:release -d:openssl`, if the previous build fails

If you want to compile to Javascript, run the following command, and you'll have a nice fdm.js file

`nim js -d=release -d=ssl -o=./fdm.js src/fdm.nim`

Note That error messages will not have color and you can't import remote files in the Javascript version.


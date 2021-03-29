# GOMPILER
C based compiler written for switch and repeat-until constructs in GO Lang.

![alt text](https://github.com/tanishqvyas/GOmpiler/blob/master/README/logobanner.jpeg)


## Installation Instructions

**1. Installing Lex**

On Linux
```
sudo apt-get install flex
```

**2. Installing Yacc**

On Linux
```
sudo apt-get install bison
```

## Workflow

![alt text](https://github.com/tanishqvyas/GOmpiler/blob/master/README/workflow.jpeg)

## Execution Instructions

The ```-d``` option helps generate the y.tab.h file needed for further execution. Replace the ```<parser-filename.y>``` with respective file name.

```
yacc -d <parser-filename.y>
```
Replace the ```<scanner-filename.y``` with respective file name.
```
lex <scanner-filename.l>
```

```
gcc y.tab.c lex.yy.c
```

```
./a.out test.go
```
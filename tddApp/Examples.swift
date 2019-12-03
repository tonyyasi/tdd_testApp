//
//  Examples.swift
//  tddApp
//
//  Created by Tony Toussaint on 11/26/19.
//  Copyright © 2019 Tony Toussaint. All rights reserved.
//

import Foundation

let fib = """
#*
    %% Getting the nth Fibonacci number
    @param int n %% The number of the sequence we want
    @return int %% El numero de la secuencia
    @test (10) => 55
*#
int fib(int n) {
    if (n == 1 || n == 0) {

        return n;
    }
    return fib(n-1) + fib(n-2);

}

    main() {
        print(fib(10));
    }
"""

let fact = """
#*
    %% Getting the factorial of something
    @param int n %% The number of which we want the factorial
    @return int %% El numero de la secuencia
    @test (10) => 3628800
*#
int fact(int n) {
    if (n == 1) {

        return 1;
    }
    return (n * fact(n-1));

}

    main() {
        print(fact(10));
    }

"""

let defaultTemplate = """
    main() {
    print("Hello World!");
}
"""

let find = """
#*
%% Finds value in an array and returns index
@param int arr %% Array that will searched
@param int val %% Value to find
*#
int find(int arr[10], int val) {
    int index;
    index = 0;
    while (index < 10) {
        if (arr[index] == val) {

            return index;
        }
        index = index + 1;
    }
    return -1;
}

    main() {
        int arr[10];
        arr[0] = 4;
        arr[1] = 2;
        arr[2] = 1;
        arr[3] = 6;
        arr[4] = 1;
        arr[5] = 19;
        arr[6] = 22;
        arr[7] = 34;
        arr[8] = 55;
        arr[9] = 45;
        print(find(arr,34));
    }
"""

let bubble = """
#*
%% Print an array
@param int arr %% Array that will be printed
*#
void printArray(int arr[10]) {
    int index;
    index = 0;
    while (index < 10) {
        print(arr[index]);
        index = index + 1;
    }
}

#*
%% Bubble sort
@param int arr %% Array that will be sorted
*#
void sort(int arr[10]) {
    bool swaped;
    int index, n, tmp;
    swaped = true;
    while (swaped == true) {
        swaped = false;
        index = 0;
        while (index < 10) {
            n = index + 1;
            if (arr[index] > arr[n]) {
                tmp = arr[index];
                arr[index] = arr[n];
                arr[n] = tmp;
                swaped = true;
            }
            index = index + 1;
        }
    }
    printArray(arr);
}

    main() {
        int arr[10];
        arr[0] = 4;
        arr[1] = 2;
        arr[2] = 1;
        arr[3] = 6;
        arr[4] = 8;
        arr[5] = 19;
        arr[6] = 22;
        arr[7] = 34;
        arr[8] = 55;
        arr[9] = 45;
        print("Arreglo original");
        printArray(arr);
        print("Sorted");
        sort(arr);
    }
"""

let printMat = """
#*
%% Print a matrix
@param int mat %% Matrix that will be printed
*#
void printMat(int mat[3][3]) {
 int y, x;
  y = 0;
  x = 0;
  while (y < 3) {
     while(x < 3) {
          print(mat[y][x]);
          x = x + 1;
      }
      x = 0;
      y = y + 1;
  }
}

main() {

int mat[3][3];
mat[0][0] = 1;
mat[0][1] = 22;
mat[0][2] = 33;
mat[1][0] = 8;
mat[1][1] = 3;
mat[1][2] = 1;
mat[2][0] = 5;
mat[2][1] = 16;
mat[2][2] = 28;
printMat(mat);
}
"""

let fact2 = """
main() {
int n, fact, i;
i = 1;
fact = 1;
n = read(int);
while(i <= n) {
        fact = fact * i;
        i = i + 1;
    }
    print(fact);
}

"""

let manyInOne = """

#*
    %% Getting the nth Fibonacci number
    @param int n %% The number of the sequence we want
    @return int %% El numero de la secuencia
    @test (10) => 55
*#
int fib(int n) {
    if (n == 1 || n == 0) {

        return n;
    }
    return fib(n-1) + fib(n-2);

}

#*
%% Print a matrix
@param int mat %% Matrix that will be printed
*#
void printMat(int mat[3][3]) {
 int y, x;
  y = 0;
  x = 0;
  while (y < 3) {
     while(x < 3) {
          print(mat[y][x]);
          x = x + 1;
      }
      x = 0;
      y = y + 1;
  }
}

#*
%% Print an array
@param int arr %% Array that will be printed
*#
void printArray(int arr[10]) {
    int index;
    index = 0;
    while (index < 10) {
        print(arr[index]);
        index = index + 1;
    }
}

#*
%% Bubble sort
@param int arr %% Array that will be sorted
*#
void sort(int arr[10]) {
    bool swaped;
    int index, n, tmp;
    swaped = true;
    while (swaped == true) {
        swaped = false;
        index = 0;
        while (index < 10) {
            n = index + 1;
            if (arr[index] > arr[n]) {
                tmp = arr[index];
                arr[index] = arr[n];
                arr[n] = tmp;
                swaped = true;
            }
            index = index + 1;
        }
    }
    printArray(arr);
}

#*
    %% Getting the factorial of something
    @param int n %% The number of which we want the factorial
    @return int %% El numero de la secuencia
    @test (10) => 3628800
*#
int fact(int n) {
    if (n == 1) {

        return 1;
    }
    return (n * fact(n-1));

}


main() {

    print("Mucha Documentacion");

}

"""

let stringConcat = """
    
main() {
    
    string hello, world;
    hello = "Hello";
    world = " world";
    print(hello + world);
}

"""

public let examples = [
    Code(title: "Default Template", code: defaultTemplate),
    Code(title: "Fibonacci", code: fib),
    Code(title: "Factorial", code: fact),
    Code(title: "Find", code: find),
    Code(title: "Bubble Sort", code: bubble),
    Code(title: "Print Matrix", code: printMat),
    Code(title: "Mucha Doc", code: manyInOne),
    Code(title: "String Concat", code: stringConcat),
    Code(title: "Read", code: fact2)
]

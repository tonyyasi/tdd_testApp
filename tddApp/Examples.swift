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
        print("Sorted");
        sort(arr);
    }


"""

public let examples = [
    Code(title: "Default Template", code: defaultTemplate),
    Code(title: "Fibonacci", code: fib),
    Code(title: "Factorial", code: fact),
    Code(title: "Find", code: find),
    Code(title: "Bubble Sort", code: bubble)
]

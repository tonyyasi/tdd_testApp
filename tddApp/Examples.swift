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
%% A function to calculate the n number in the fibonacci sequence
@param int n %% The number of the fibonacci sequence we want to calculate

@return int %% The calculated number

@test (5) => 3

*#

int fib(int n) {
    if (x == 1 || x == 0) {
        return x;
    }
    return (fib(x-1) + fib(x-2));
}

main() {
    fib(5);
}
"""

let fact = """
#*
%% A function to calculate the factorial of a number
@param int n %% The number we want to calculate the factorial for

@return int %% The factorial of the number

@test (5) => 120

*#

int factorial(int n) {
    if (n == 1) {
        return 1;
    }

    return (n * factorial(n-1));

}

main() {
    factorial(5);
}

"""

let defaultTemplate = """
    int main() {
    print("Hello World!");
}
"""

public let examples = [
    Code(title: "Default Template", code: defaultTemplate),
    Code(title: "Fibonacci", code: fib),
    Code(title: "Factorial", code: fact)
]

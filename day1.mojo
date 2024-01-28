import pathlib
from python import Python

fn get_digit_sum(value: String) raises -> Int:
    Python.add_to_path(".")
    let mypython = Python.import_module("mypython")
    
    var sum: Int = 0
    var first: Int = -1
    var prev: Int = 0
    for c in range(len(value)+1): #loops through each character in string
        if(mypython.is_numeric(value[c]) == True):
            if(first == -1): #If this is the first occurence of a digit in the string
                first = atol(value[c]) #atol converts str to int
                prev = atol(value[c])
            else: #If this is any other occurence of a digit
                prev = atol(value[c])
        elif(value[c] == "\n"): #If we're at a newline
            first*=10
            sum += first + prev
            first = -1
            prev = 0
    first*=10
    sum += first + prev
    return sum


def main():

    let p: Path = Path("./test.txt")
    let str : String = p.read_text()

    print(get_digit_sum(str))


    
import pathlib
from python import Python
from python.object import PythonObject

fn get_digit_sum(value: String) raises -> Int:
    Python.add_to_path(".")
    let mypython = Python.import_module("mypython")

    var dict = Python.dict()
    dict["one"] = 1
    dict["two"] = 2
    dict["three"] = 3
    dict["four"] = 4
    dict["five"] = 5
    dict["six"] = 6
    dict["seven"] = 7
    dict["eight"] = 8
    dict["nine"] = 9

    let splits = value.split("\n") # Splits the value string into smaller strings split by newline 



    var value_test = value
    for key in dict:
        var index: Int = value_test.find(key.__str__(),0)
        while(index !=-1):
            value_test = value_test[0:index+1] + dict[key].__str__() + value_test[index+1:] #appends string int in middle of the text int
            index+= len(key.__str__())
            if(value_test.find(key.__str__(),index)!= -1):
                index += value_test.find(key.__str__(),index)
            else:
                index = -1  
    var sum: Int = 0
    var first: Int = -1
    var prev: Int = 0
     
    for i in range(len(value_test)): #loops through each string
        if(mypython.is_numeric(value_test[i]) == True):
            if(first == -1):
                first = atol(value_test[i]) #atol converts str to int
                prev = atol(value_test[i])
            else:
                prev = atol(value_test[i])
        elif(value_test[i] == "\n"):
            first*=10
            print(first,prev)
            sum += first + prev
            first = -1
            prev = 0
    first*=10
    sum += first + prev
    return sum


fn main() raises:

    let p: Path = Path("./test.txt")
    let str : String = p.read_text()

    print(get_digit_sum(str))




    
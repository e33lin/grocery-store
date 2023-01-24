import sys
import ast

grocery_list = ast.literal_eval(sys.argv[1]) # read argument 

d = {
   "1":{
      "store":"store1",
      "cost":5.0,
      "list":grocery_list
   },
   "2":{
      "store":"store2",
      "cost":10.0,
      "list":grocery_list
   }
}

print(d)
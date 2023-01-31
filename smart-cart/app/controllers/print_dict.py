import sys
import ast

grocery_list = ast.literal_eval(sys.argv[1]) # read argument 

d = {
   "1":{
      "store":"store1",
      "subtotal":5.0,
      "results":{
         "list_item1": "milk",
         "list_item2": "eggs",
      }
   },
   "2":{
      "store":"store2",
      "subtotal":10.0,
      "results":{
         "list_item1": "milk",
         "list_item2": "eggs",
      }
   },
   "3":{
      "store":"store3",
      "subtotal":15.0,
      "results":{
         "list_item1": "milk",
         "list_item2": "eggs",
      }
   }
}

print(d)
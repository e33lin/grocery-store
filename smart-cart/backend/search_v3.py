'''
Script to search each stores catologe of data for a users specified grocery list 

Format to run:
python search_v3.py <grocery_list> <n_stores>

EX: python search_v3.py "['2% milk', 'Cheddar Cheese', 'white sliced bread']" 2

grocery_list must be passed with " " around the actual list object 

'''
 
import pandas as pd
import numpy as np
from nltk.stem import PorterStemmer
from nltk.metrics.distance import jaccard_distance
from fuzzywuzzy import process
import time
import sys
import ast
from pickle import load
import json 
import warnings
warnings.filterwarnings("ignore")

import cost_minimization as cost_min

start_time = time.time()

ps = PorterStemmer() # stemming for better results 


# take arguments from terminal 
grocery_list = ast.literal_eval(sys.argv[1])
n_stores = ast.literal_eval(sys.argv[2])


# https://www.educative.io/answers/what-is-the-jaccard-similarity-measure-in-nlp
def jaccard_similarity(string1, string2):
    return (1 - jaccard_distance(set(string1.lower().split(' ')), set(string2.lower().split(' ')))) * 100


def search(grocery_list, ps):
    stores = ['zehrs', 'no_frills', 'valu_mart', 'sobeys', 'freshco'] #, 'walmart', 'food_basics']

    # make variables 
    for store in stores:
        globals()[f"{store}_results"] = pd.DataFrame() # dynamically create variable names 

        
    for store in stores: # retrieval for each store 
        
        # load data
        store_data = pd.read_csv(f'../../data/{store}/{store}_data.csv')
        
        final_selection = pd.DataFrame()

        for item in grocery_list:
            data = store_data

            # pulls obs that have product name most similar to the list item 
            # truncate at 20
            most_similar = process.extract(item, data['product'], scorer=jaccard_similarity, limit=20)  

            # collect indexes for most similar obs 
            idxs = []
            sims = []
            for product in most_similar: 
                if product[1] >= 50: 
                    idxs.append(product[2])
                    sims.append(product[1])

            # secondary search 
            if len(idxs) == 0: # try with lower sim threshold
                for product in most_similar: 
                    if product[1] >= 25: 
                        idxs.append(product[2])
                        sims.append(product[1])

            selected_data = data.iloc[idxs]
            
            selected_data['list_item']= item

            selected_data['similarity']= sims

            # comparable price: sale_price if is_sale, price if not is_sale
            selected_data['comparable_PUP'] = np.where(selected_data['is_sale'] == True, selected_data['sale_per_unit_price'], selected_data['per_unit_price'])
            selected_data['comparable_price'] = np.where(selected_data['is_sale'] == True, selected_data['sale_price'], selected_data['price'])

            try:
                # take the cheapest item 
                cheapest_item = selected_data.sort_values(by=['comparable_PUP', 'similarity'], ascending = [True, False])

                if len(cheapest_item) != 0:
                    cheapest_item = cheapest_item.iloc[0]
                    cheapest_item['missing'] = False
                    final_selection = final_selection.append(dict(cheapest_item), ignore_index=True)
                else:  # no item found
                    final_selection = final_selection.append({'store': store
                            , 'category': None
                            , 'brand': None
                            , 'product': None
                            , 'full_product_text':None
                            , 'price': None
                            , 'sale_price': None
                            , 'price_unit': None
                            , 'per_unit_price': None
                            , 'sale_per_unit_price': None
                            , 'units': None
                            , 'price_per_1': None
                            , 'is_sale': None
                            , 'list_price': None
                            , 'list_item': item
                            , 'similarity': None
                            , 'comparable_PUP': 0
                            , 'comparable_price': 0
                            , 'missing': True
                            }, ignore_index=True)
            except: continue

                
        globals()[f"{store}_results"] = final_selection

        # cast booleans to be consistent 
        globals()[f"{store}_results"]['is_sale'].replace({0: False, 1: True}, inplace=True)
        globals()[f"{store}_results"]['missing'].replace({0: False, 1: True}, inplace=True)

        # FOR TESTING 
        # dump results to csv 
        # globals()[f"{store}_results"].to_csv(f'{store}_results.csv', index=False)
    
    return {'zehrs': zehrs_results
        , 'no_frills': no_frills_results
        , 'valu_mart': valu_mart_results
        , 'sobeys': sobeys_results
        , 'freshco': freshco_results
        # , 'walmart': walmart_results
        # , 'food_basics': food_basics_results
        }


results_dict = search(grocery_list, ps)

output = cost_min.n_store_selection(n_stores, results_dict, grocery_list)

 # FOR TESTING 
# with open("output.json", "w") as outfile:
#     json.dump(output, outfile, indent=4)

# print(output)
print(json.dumps(output, indent = 4))
    
# print(f'completed in {time.time() - start_time} seconds')
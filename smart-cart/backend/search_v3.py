'''
Script to search each stores catologe of data for a users specified grocery list 
Format to run:
python search_v3.py <grocery_list> <n_stores>
EX: python search_v3.py "['2% milk', 'Cheddar Cheese', 'white sliced bread']" 2
grocery_list must be passed with " " around the actual list object 
'''
 
import pandas as pd
from nltk.stem import PorterStemmer
from nltk.metrics.distance import jaccard_distance
from fuzzywuzzy import process
import time
import sys
import os 
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

# def get_rel(search_item, product):
#     rel = 0
#     try:
#         for word in search_item.split(' '):
#             rel += (ps.stem(product).lower().replace(',', '').split(' ').index(word)+1) / len(product.split(' '))

#         rel = rel / len(search_item.split(' '))
#     except: 
#         rel = 0
#     return rel


def search(grocery_list, ps):
    stores = ['zehrs', 'no_frills', 'valu_mart', 'sobeys', 'freshco', 'walmart', 'food_basics']

    # make variables 
    for store in stores:
        globals()[f"{store}_results"] = pd.DataFrame() # dynamically create variable names 

        
    for store in stores: # retrieval for each store 
        
        # load data
        # store_data = pd.read_csv(f'app/data/{store}/{store}_data.csv')
        file_path = os.path.join(os.getcwd(), 'app', 'data', f'{store}', f'{store}_data.csv')
        store_data = pd.read_csv(file_path)
        
        final_selection = pd.DataFrame()

        for item in grocery_list:
            # item = ps.stem(item)

            if 'frozen' in item:  # solves frozen problem 
                data = store_data.loc[store_data['category'] == 'frozen'].reset_index()
                search_item = item.replace('frozen', '').strip()
            else: 
                data = store_data
                search_item = item

            # pulls obs that have product name most similar to the list item 
            # truncate at 10
            # most_similar = process.extract(item, data['product'], scorer=jaccard_similarity, limit=20)  
            most_similar = process.extract(search_item, data['product'],  limit=10)
            
            # collect indexes for most similar obs 
            idxs = []
            sims = []
            # rels = []
            for product in most_similar: 

                if product[1] >= 60: 
                    idxs.append(product[2])
                    sims.append(product[1])
                    # rels.append(get_rel(search_item, product[0]))

            # secondary search 
            if len(idxs) == 0: # try with lower sim threshold    
                for product in most_similar: 

                    if product[1] >= 50: 
                        idxs.append(product[2])
                        sims.append(product[1])
                        # rels.append(get_rel(search_item, product[0]))

            selected_data = data.iloc[idxs]
            
            selected_data['list_item']= item

            selected_data['similarity']= sims

            # selected_data['relevance'] = rels

            # comparable price: sale_price if is_sale, price if not is_sale
            if len(selected_data) > 0: # if items are found
                selected_data['comparable_PUP'] = selected_data.apply(lambda row: row['sale_per_unit_price'] if row.is_sale else row['per_unit_price'], axis=1)
                selected_data['comparable_price'] = selected_data.apply(lambda row: row['sale_price'] if row.is_sale else row['price'], axis=1)
            else:
                selected_data['comparable_PUP'] = None
                selected_data['comparable_price'] = None

            # selected_data['weight'] = (1 - selected_data.similarity + 0.1) * selected_data.comparable_PUP

            try:
                # take the cheapest item 
                # cheapest_item = selected_data.sort_values(by=['comparable_PUP','similarity'], ascending = [True, False])
                cheapest_item = selected_data.sort_values(by=['similarity', 'comparable_PUP'], ascending = [False, True])
                # cheapest_item = selected_data.sort_values(by=['weight'], ascending = True)

                # print(cheapest_item)

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
                            , 'sale_valid_until': None
                            , 'data_last_refreshed_at': None
                            , 'list_price': None
                            , 'list_item': item
                            , 'similarity': None
                            , 'comparable_PUP': 0
                            , 'comparable_price': 0
                            , 'missing': True
                            }, ignore_index=True)
            except: continue

        print(final_selection.columns)   
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
        , 'walmart': walmart_results
        , 'food_basics': food_basics_results
        }


results_dict = search(grocery_list, ps)

output = cost_min.n_store_selection(n_stores, results_dict, grocery_list)

 # FOR TESTING 
# with open("output.json", "w") as outfile:
#     json.dump(output, outfile, indent=4)

#print(output)
print(json.dumps(output, indent = 4))

# print(f'completed in {time.time() - start_time} seconds')
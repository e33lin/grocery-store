'''
Script to search each stores catologe of data for a users specified grocery list 

Format to run:
python search_v4.py <grocery_list> <n_stores>

EX: python search_v4.py "['2% milk', 'Cheddar Cheese', 'white sliced bread']" 2

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
# quantities = ast.literal_eval(sys.argv[2])
n_stores = ast.literal_eval(sys.argv[2])



# https://www.educative.io/answers/what-is-the-jaccard-similarity-measure-in-nlp
def jaccard_similarity(string1, string2):
    return (1 - jaccard_distance(set(string1.lower().split(' ')), set(string2.lower().split(' ')))) * 100

def get_rel(search_item, product):

    try:
        cat_item = search_item.replace(' ', '-')
        product = product.replace(search_item, cat_item)

        # comma usually is used for descriptors - move descriptors to front 
        # ex: frozen perogies, pizza - is usally labelled as pizza but really its perogies
        # to fix we ust rearrange into pizza frozen perogies 
        if ', ' in product:
            x = product.split(', ')
            product = x[1] + x[0]
        elif 'with' in product:
            x = product.split('with ')
            product = x[1] + x[0]
        elif '- ' in product:
            x = product.split('- ')
            product = x[1] + x[0]

        prod_list = product.split(' ')

        return (prod_list.index(cat_item)+1) / len(prod_list)
    except: 
        # print(search_item, product)
        return 0


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
        store_index = load(open(os.path.join(os.getcwd(), 'app', 'catalogue_index', f'{store}_index.pkl'),'rb'))

        store_data['is_sale'].replace({'0.0': False, '1.0': True}, inplace=True)
        
        # set df 
        final_selection = pd.DataFrame()


        for item in grocery_list:
            stem_item = ps.stem(item)
            idxs = [] # indexes of relevant items 

            # find all rel products based on stemmed item 
            for word in stem_item.split():
                try: # list item word not in index
                    word_idxs = store_index[word]
                    idxs.extend(word_idxs)
                except: continue

            # filter for those rel products 
            if 'frozen' in item: 
                # frozen items usall dont have the word frozen in it, need to explicity tell 
                # the system that we want frozen category items 
                store_df = store_data.loc[store_data['category'] == 'frozen'].reset_index()
                search_item = item.replace('frozen', '').strip()
            else:
                if not idxs: # no indicies returned
                    store_df = pd.DataFrame() # no results: return empty df
                    search_item = item
                else:
                    store_df = store_data.iloc[idxs].reset_index()
                    search_item = item


            # calculates the "relevance" score of the product based on the item 
            sims = []
            idxs = []
            ##### search items #####
            for index, row in store_df.iterrows():
                
                product_name = row['product']

                rel_score = get_rel(ps.stem(search_item), ps.stem(product_name))

                if rel_score == 0.8:
                    sims.append(rel_score)
                    idxs.append(index)

            # take all items that have high rel scroe 
            selected_data = store_df.iloc[idxs]
            selected_data['list_item'] = item
            selected_data['similarity'] = sims

            # comparable price: sale_price if is_sale, price if not is_sale
            if len(selected_data) > 0: # if items are found
                selected_data['comparable_PUP'] = selected_data.apply(lambda row: row['sale_per_unit_price'] if row.is_sale else row['per_unit_price'], axis=1)
                selected_data['comparable_price'] = selected_data.apply(lambda row: row['sale_price'] if row.is_sale else row['price'], axis=1)
            else:
                selected_data['comparable_PUP'] = None
                selected_data['comparable_price'] = None


            try:
                # take the cheapest item 
                cheapest_item = selected_data.sort_values(by=['similarity', 'comparable_PUP'], ascending = [False, True])

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

# print(output)

print(json.dumps(output, indent = 4))

# print(f'completed in {time.time() - start_time} seconds')
''' 
functions to identify which store(s) or combination stores results in the lowest 
per unit subtotal cost  

Works for any n combinations so long as n <= num_stores

Bulk of the computation happens in here to compare store pricing 
'''

import pandas as pd 
from itertools import combinations, chain


def check_for_missing_items(grocery_list, results_dict, manipulated_results_dict = {}):
    '''Make a copy (manipulated) dict that doesnt include any missing values in all store dfs 
    even if only one store is missing items'''

    missing_items = []
    
    for key in results_dict.keys():
        df = results_dict[key]
        items_found = list(df.list_item.unique())

        missing_items.extend([x for x in grocery_list if x not in items_found])
    
    for key in results_dict.keys():
        df = results_dict[key]

        df = df[~ df['list_item'].isin(missing_items)]

        manipulated_results_dict[key] = df

    return manipulated_results_dict, results_dict



def item_selection(dfs):
    '''Select if item x shoudl come from store A or store B'''
    
    # append all dfs
    df = dfs[0]
    dfs.remove(dfs[0])
    for df_n in dfs:
        df = df.append(df_n, ignore_index=True)

    # group by list_items 
    df_grp = df.groupby('list_item')['comparable_PUP']

    # add col indicating min cost out of the n store dfs 
    df = df.assign(min_cost=df_grp.transform(min))

    # filter rows where the row corresponds to the min cost 
    # df = df[df['comparable_PUP'] == df['min_cost']]
    df = df.sort_values(by=['list_item','comparable_PUP'])
    df = df.groupby('list_item').nth(0).reset_index()

    per_unit_subtotal = sum(df['comparable_PUP'])
    subtotal = sum(df['comparable_price'])

    return df, per_unit_subtotal, subtotal 


def final_json(PUP_subtotal_results, subtotal_results, output_results, results = 3):
    '''build json output'''

    output = {}

    # sorted_dict = dict(sorted(PUP_subtotal_results.items(), key=lambda item: item[1]))
    # sort by manipulated pup then by regular pup for stores that have all data
    sorted_dict = dict(sorted(PUP_subtotal_results.items(), key=lambda x: (x[1][0], x[1][1])))

    keys_in_order = list(sorted_dict.keys())

    for i in range(results):
        store_s = keys_in_order[i]

        # clean up results to be returned 
        df_results = output_results[store_s]
        df_results = df_results.drop(columns=['similarity', 'comparable_PUP', 'sale_price',
                        'sale_per_unit_price', 'per_unit_price', 'min_cost', 'price_per_1'])
        df_results = df_results[['list_item', 'store', 'category', 'brand', 'product', 'full_product_text', 'comparable_price', 'price_unit', 'is_sale']].rename(columns={'comparable_price': 'price'})


        output[f"{i+1}"] = {'store': store_s
                    , 'subtotal': subtotal_results[store_s]
                    , 'results': df_results.to_dict('list')
                    }
    return output
    

def n_store_selection(n, results_dict, grocery_list):
    '''iterate through all n store combinations to select cheapest store combinations'''

    subtotal_results, output_results, PUP_subtotal_results = {}, {}, {}

    if n >= len(results_dict):
        print(f'{n} combinations not possible for our {len(results_dict)} store selection')
        return {}

    manipulated_results_dict, results_dict = check_for_missing_items(grocery_list, results_dict)

    # go through n combination stores 
    # possibilities = list(combinations(results_dict.keys(), n))
    possibilities = list(chain.from_iterable(combinations(results_dict.keys(), m) for m in range(1, n+1))) # up to n stores 
    for combin in possibilities:
        
        # place all dfs in list 
        dfs = []
        manipulated_dfs = []
        for store in combin:
            manipulated_dfs.append(manipulated_results_dict[store])
            dfs.append(results_dict[store])

        # item selection 
        optimal_selection, per_unit_subtotal, subtotal = item_selection(dfs)
        manipulated_optimal_selection, manipulated_per_unit_subtotal, manipulated_subtotal = item_selection(manipulated_dfs)

        # add to results dict 
        stores = tuple(optimal_selection.store.unique())

        PUP_subtotal_results[stores] = [manipulated_per_unit_subtotal, per_unit_subtotal] # we want to compare without missing items when applicable
        subtotal_results[stores] = subtotal
        output_results[stores] = optimal_selection

    return final_json(PUP_subtotal_results, subtotal_results, output_results)


''' 
functions to identify which store(s) or combination stores results in the lowest 
per unit subtotal cost 

Works for any n combinations so long as n <= num_stores
'''

import pandas as pd 
from itertools import combinations


def item_selection(dfs):
    
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
    df = df[df['comparable_PUP'] == df['min_cost']]

    # take subtotal 
    per_unit_subtotal = sum(df['comparable_PUP'])
    subtotal = sum(df['comparable_price'])

    return df, per_unit_subtotal, subtotal 


def n_store_selection(n, results_dict, subtotal_results = {}, PUP_subtotal_results = {}, output_results = {}):

    if n >= len(results_dict):
        print(f'{n} combinations not possible for our {len(results_dict)} store selection')
        return {}

    # go through n combination stores 
    possibilities = list(combinations(results_dict.keys(), n))
    for combin in possibilities:
        
        # place all dfs in list 
        dfs = []
        for store in combin:
            # df = pd.read_csv(f'search_output/{store}_results.csv')
            df = results_dict[store]
            dfs.append(df)

        # item selection 
        optimal_selection, per_unit_subtotal, subtotal = item_selection(dfs)

        # add to results dict 

        PUP_subtotal_results[combin] = per_unit_subtotal
        subtotal_results[combin] = subtotal
        output_results[combin] = optimal_selection

    return final_json(PUP_subtotal_results, subtotal_results, output_results)

    # return subtotal_results, output_results


def final_json(PUP_subtotal_results, subtotal_results, output_results):
    output = {}

    sorted_dict = dict(sorted(PUP_subtotal_results.items(), key=lambda item: item[1]))

    keys_in_order = list(sorted_dict.keys())

    for i in range(3):
        store_s = keys_in_order[i]

        df_results = output_results[store_s].drop(columns=['Unnamed: 0'])


        output[i+1] = {'store': store_s
                    , 'subtotal': subtotal_results[store_s]
                    , 'results': df_results.to_dict('list')
                    }
    return output
    

class RecommendationsController < ApplicationController

    def stores
        $n_stores = params[:n_stores]
        # since the system goes through /stores to get to /recommendations when submitting their list,
        # we set this session variable as true in this method
        session[:from_list_page] = true 
        redirect_to recommendations_path
    end
    

    def show
        session_id = session[:current_user_id]
        
        list_objects = List.where(list_id: session_id)
        list = List.list_as_array(list_objects)
        quantities = List.item_quantities_as_array(list_objects)
        n_stores = $n_stores

        # check if there is already an entry in Recommendations for the current user (first-time user)
        # if it is a first-time user (no recs saved), then we will generate recommendations (search_v4.py)
        if (Recommendation.find_by(list_id: session_id).blank?)
            require 'json'
            magic(session_id, list, n_stores, quantities)

        # otherwise, the user has been on smartcart before! so they have existing recommendations  
        else

            first_rec = Recommendation.find_by(list_id: session_id, rec_num: 1)
            second_rec = Recommendation.find_by(list_id: session_id, rec_num: 2)
            third_rec = Recommendation.find_by(list_id: session_id, rec_num: 3)

            list_items = []
            first_rec.rec.each do |key, value|
                if (key == "list_item")
                    list_items = value
                end
            end

            # if the user is NOT visiting from the list builder page (i.e., they are coming to all recs after viewing a single rec)
            # then we just render their existing recs for them
            if (session[:from_list_page].nil?)
                $subtotals = [first_rec.subtotal, second_rec.subtotal, third_rec.subtotal]
                $stores = [first_rec.store, second_rec.store, third_rec.store]

                $unknown = []
                $unknown[0] = []
                $unknown[1] = []
                $unknown[2] = []

                $last_data_refresh = []
                first_rec.rec.each do |key, value| # parse the first rec for its unknown items
                    if (key == "data_last_refreshed_at")
                        $last_data_refresh = value
                        print $last_data_refresh
                    elsif (key == "full_product_text")
                        products = value
                        for y in 0..products.length()-1 
                            if (products[y].nil?)
                                $unknown[0].push(list_items[y])  
                            end
                        end
                    end
                end

                second_rec.rec.each do |key, value| # parse the second rec for its unknown items
                    if (key == "full_product_text")
                        products = value
                        for y in 0..products.length()-1 
                            if (products[y].nil?)
                                $unknown[1].push(list_items[y])  
                            end
                        end
                    end
                end

                third_rec.rec.each do |key, value| # parse the third rec for its unknown items
                    if (key == "full_product_text")
                        products = value
                        for y in 0..products.length()-1 
                            if (products[y].nil?)
                                $unknown[2].push(list_items[y])  
                            end
                        end
                    end
                end
    
            # if the user IS coming from the list builder page, we assume there are changes on their list
            # we delete those existing recs and rerun the search script to generate new recs
            else 
                first_rec.destroy
                second_rec.destroy
                third_rec.destroy
                
                magic(session_id, list, n_stores, quantities)
            end
        end 
        session.delete(:from_list_page)
    end

    def number
        session_id = session[:current_user_id]
        list_objects = List.where(list_id: session_id)
        $list_items = List.list_as_array(list_objects)
        $quantities = List.item_quantities_as_array(list_objects)
        $current_recommendation = Recommendation.find_by(list_id: session_id, rec_num: params[:id]) #idk why the params[:id] isnt returning anything
        $num = params[:id]
        $list = []
        $products = []
        $prices = []
        $is_sale = []
        $stores = []
        $sale_dates = []
        $last_data_refresh = []
        $prod = []
        $current_recommendation.rec.each do |key, value| # parses all the information, used as-is for 1 store view
            if (key == "full_product_text")
                $products = value
            elsif (key == "price")
                $prices = value
            elsif (key == "is_sale")
                $is_sale = value
            elsif (key == "list_item")
                $list = value
            elsif (key == "store")
                $stores = value
            elsif (key == "sale_valid_until")
                $sale_dates = value
            elsif (key == "data_last_refreshed_at")
                $last_data_refresh = value
            elsif (key == "product")
                $prod = value

            end
        end

        print $last_data_refresh

        $first_store_products = []
        $second_store_products = []
        $first_store_prices = []
        $second_store_prices = []
        $first_store_is_sale = []
        $second_store_is_sale = []
        $first_store_sale_date = []
        $second_store_sale_date = []
        $first_store_quantities = []
        $second_store_quantities = []
        $first_store_prod = []
        $second_store_prod = []
        $first_store_list = []
        $second_store_list = []
        i = 0
        if ($current_recommendation.store.length() > 1)
            for store in $stores
                if (store == $current_recommendation.store[0])
                    $first_store_products.append($products[i])
                    $first_store_prices.append($prices[i])
                    $first_store_is_sale.append($is_sale[i])
                    $first_store_sale_date.append($sale_dates[i])
                    $first_store_quantities.append($quantities[i])
                    $first_store_list.append($list[i])
                    $first_store_prod.append($prod[i])
                else
                    $second_store_products.append($products[i])
                    $second_store_prices.append($prices[i])
                    $second_store_is_sale.append($is_sale[i])
                    $second_store_sale_date.append($sale_dates[i])
                    $second_store_quantities.append($quantities[i])
                    $second_store_list.append($list[i])
                    $second_store_prod.append($prod[i])
                end
                i += 1
            end
        end
    end

    private

    # search and parse
    def magic(session_id, list, n_stores, quantities)
        result = `python3 -W ignore #{ENV["PWD"] + "/backend/search_v4.py"} '#{list}' #{n_stores}` # pass l as an argument 
        print result
        hash = JSON.parse(result, { allow_nan: true }) # turn string result into a hash
        $stores = [hash['1']['store'], hash['2']['store'], hash['3']['store']]

        store = ""
        subtotal = ""
        $subtotals = []
        results = ""
        $last_data_refresh = []
        $unknown = []

        $unknown[0] = []
        $unknown[1] = []
        $unknown[2] = []

        a=0
        
        hash.each do |rank, rec_data|
            $products = []
            $list = []
            rec_data.each do |key, value|
                if (key == "store")
                    store = value
                elsif (key == "subtotal")
                    subtotal = value
                else
                    results = value
                end
            end
            
            results.each do |key, value|
                if (key == "price")
                    prices = value
                    i = 0
                    for x in quantities
                        if (x > 1) # if the quantity of an item is > 1
                            item_price = prices[i] # grab the per unit price
                            additional_item_price = item_price * (x-1) # multiply by x-1. if x = 2, additional_item_price is the same as item_price
                            subtotal += additional_item_price # tack on the additional_item_price to subtotal
                        end
                        i += 1
                    end
                elsif (key == "data_last_refreshed_at")
                    $last_data_refresh = value
                    
                elsif (key == "full_product_text")
                    $products = value
                    for y in 0..$products.length()-1 
                        if ($products[y].nil?)
                            if (a==0)
                                $unknown[0].push($list[y]) 
                                print $unknown[0]
                            elsif (a==1)
                                $unknown[1].push($list[y]) 
                                print $unknown[1]
                            elsif  
                                $unknown[2].push($list[y]) 
                                print $unknown[2]
                            end
                        end
                    end
                elsif (key == "list_item")
                    $list = value
                end

                
            end
            subtotal = subtotal.round(2)
            $subtotals.append(subtotal)
            Recommendation.create(list_id: session_id, rec_num:rank, store:store, subtotal:subtotal, rec:results)

            a+= 1
        end
    end
end
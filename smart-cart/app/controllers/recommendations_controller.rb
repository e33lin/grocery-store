class RecommendationsController < ApplicationController

    def stores
        $n_stores = params[:n_stores] 
        redirect_to recommendations_path
    end
    

    def show
        session_id = session[:current_user_id]

        # check if there is already an entry in Recommendations for the current user
        # if not, then we will save the recommendations generated by search_v3.py to Recommendations table
        if (Recommendation.find_by(list_id: session_id).blank?)
            require 'json'
            list_objects = List.where(list_id: session_id)
            list = List.list_as_array(list_objects)
            quantities = List.item_quantities_as_array(list_objects)
            n_stores = $n_stores

            result = `python3 -W ignore #{ENV["PWD"] + "/backend/search_v3.py"} '#{list}' #{n_stores}` # pass l as an argument 
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
            print "what"
            print $unknown

        # if there is an entry in Recommendations for the current user,
        # then we will query for it in Recommendations table and simply show these   
        else
            $unknown = []
            $unknown[0] = []
            $unknown[1] = []
            $unknown[2] = []
            
            first_rec = Recommendation.find_by(list_id: session_id, rec_num: 1)
            second_rec = Recommendation.find_by(list_id: session_id, rec_num: 2)
            third_rec = Recommendation.find_by(list_id: session_id, rec_num: 3)

            all_list_items = List.where(list_id: session_id)

            $subtotals = [first_rec.subtotal, second_rec.subtotal, third_rec.subtotal]
            $stores = [first_rec.store, second_rec.store, third_rec.store]

            list_items = []
            first_rec.rec.each do |key, value|
                if (key == "list_item")
                    list_items = value
                end
            end

            if (list_items.length() != all_list_items.length())
                first_rec.destroy
                second_rec.destroy
                third_rec.destroy

                list_objects = List.where(list_id: session_id)
                list = List.list_as_array(list_objects)
                quantities = List.item_quantities_as_array(list_objects)
                n_stores = $n_stores

                result = `python3 -W ignore #{ENV["PWD"] + "/backend/search_v3.py"} '#{list}' #{n_stores}` # pass l as an argument 
                print result
                hash = JSON.parse(result, { allow_nan: true }) # turn string result into a hash
                $stores = [hash['1']['store'], hash['2']['store'], hash['3']['store']]

                store = ""
                subtotal = ""
                $subtotals = []
                results = ""
                hash.each do |rank, rec_data|
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
                        end
                    end
                    subtotal = subtotal.round(2)
                    $subtotals.append(subtotal)
                    Recommendation.create(list_id: session_id, rec_num:rank, store:store, subtotal:subtotal, rec:results)
                end
            end
        end
    end

    def number
        session_id = session[:current_user_id]
        list_objects = List.where(list_id: session_id)
        $list_items = List.list_as_array(list_objects)
        $quantities = List.item_quantities_as_array(list_objects)
        $current_recommendation = Recommendation.find_by(list_id: session_id, rec_num: params[:id])
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
        i = 0
        if ($current_recommendation.store.length() > 1)
            for store in $stores
                if (store == $current_recommendation.store[0])
                    print "hello"
                    $first_store_products.append($products[i])
                    $first_store_prices.append($prices[i])
                    $first_store_is_sale.append($is_sale[i])
                    $first_store_sale_date.append($sale_dates[i])
                    $first_store_quantities.append($quantities[i])
                    $first_store_list.append($prod[i])
                else
                    $second_store_products.append($products[i])
                    $second_store_prices.append($prices[i])
                    $second_store_is_sale.append($is_sale[i])
                    $second_store_sale_date.append($sale_dates[i])
                    $second_store_quantities.append($quantities[i])
                    $second_store_list.append($prod[i])
                end
                i += 1
            end
        end
    end
end
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
            n_stores = $n_stores

            `source ../../venv/bin/activate`
            
            result = `python3 -W ignore #{ENV["PWD"] + "/backend/search_v3.py"} '#{list}' #{n_stores}` # pass l as an argument 
            print result
            hash = JSON.parse(result) # turn string result into a hash result.gsub("'", "\"")
            $stores = [hash['1']['store'], hash['2']['store'], hash['3']['store']]

            store = ""
            subtotal = ""
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
                Recommendation.create(list_id: session_id, rec_num:rank, store:store, subtotal:subtotal, rec:results)
            end

        # if there is an entry in Recommendations for the current user,
        # then we will query for it in Recommendations table and simply show these   
        else
            first_rec = Recommendation.find_by(list_id: session_id, rec_num: 1)
            second_rec = Recommendation.find_by(list_id: session_id, rec_num: 2)
            third_rec = Recommendation.find_by(list_id: session_id, rec_num: 3)

            $stores = [first_rec.store, second_rec.store, third_rec.store]
        end
    end

    def number
        session_id = session[:current_user_id]
        rec_num = params[:rec_num]
        $current_recommendation = Recommendation.find_by(list_id: session_id, rec_num: params[:id])
        $list = []
        $brands = []
        $products = []
        $prices = []
        $is_sale = []
        $current_recommendation.rec.each do |key, value|
            if (key == "brand")
                $brands = value
            elsif (key == "product")
                $products = value
            elsif (key == "price")
                $prices = value
            elsif (key == "is_sale")
                $is_sale = value
            elsif (key == "list_item")
                $list = value
            end
        end
    end
end
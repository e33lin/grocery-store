class RecommendationsController < ApplicationController
    

    def show
        session_id = session[:current_user_id]

        # check if there is already an entry in Recommendations for the current user
        # if not, then we will save the recommendations generated by search_v3.py to Recommendations table
        #if (Recommendation.find_by(list_id: session_id).blank?)
            #require 'json'
            list_objects = List.where(list_id: session_id)
            list = List.list_as_array(list_objects)
            print list
            n_stores = 1 # TODO: reference the number of stores from create list form

            result = `python3 -W ignore #{ENV["PWD"] + "/backend/search_v3.py"} '#{list}' #{n_stores}` # pass l as an argument 
            print result
            hash = JSON.parse(result.gsub("'", "\"")) # turn string result into a hash
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
        #else
        #    first_rec = Recommendation.find_by(list_id: session_id, rec_num: 1)
        #    second_rec = Recommendation.find_by(list_id: session_id, rec_num: 2)
        #    third_rec = Recommendation.find_by(list_id: session_id, rec_num: 3)

            #$stores = [first_rec.store, second_rec.store, third_rec.store]
        #end
        
       
    end

    def number
        session_id = session[:current_user_id]
        rec_num = params[:rec_num]
        $current_recommendation = Recommendation.find_by(list_id: session_id, rec_num: params[:id])
    end
end
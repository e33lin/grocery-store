class RecommendationsController < ApplicationController
    def show
        require 'json'
        l = ['milk', 'eggs']
        result = `python3 #{ENV["PWD"] + "/app/controllers/print_dict.py"} "'#{l}'"` # pass l as an argument 
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
            Recommendation.create(list_id: 1, rec_num:rank, store:store, subtotal:subtotal, rec:results)
        end
       
    end

    def number

        rec_num = params[:rec_num]
        $current_recommendation = Recommendation.find_by(list_id: 1, rec_num: params[:id])
        #$store_name = @hash[["'#{params[:id]}'"]['store']]
    end
end
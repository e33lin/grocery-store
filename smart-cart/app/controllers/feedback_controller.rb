class FeedbackController < ApplicationController
    def show
        session_id = session[:current_user_id]
        
        list_objects = List.where(list_id: session_id)
        $list = List.list_as_array(list_objects)
        
    end

    def new
        @feedback = Feedback.new
    end

    def create
        session_id = session[:current_user_id]

        $current_recommendation = Recommendation.find_by(list_id: session_id, rec_num: params[:id]) #idk why the params[:id] isnt returning anything
        $list = []
        $stores = []
        $prod = []
        $categories = []

        $current_recommendation.rec.each do |key, value| # parses all the information, used as-is for 1 store view
            if (key == "list_item")
                $list = value
            elsif (key == "store")
                $stores = value
            elsif (key == "product")
                $prod = value
            elsif (key == "category")
                $categories = value
            end
        end

        item = params[:item]
        index = 0

        for x in 0..$list.length()-1
            if $list[x] == item
                index = x
            end

        end 
        
        change = 0
        if params[:change] == "higher"
            change = 1
        else 
            change = -1
        end 

        category = $categories[x]
        store = $stores[x]


        print category
        print store
     

        @feedback = Feedback.create(store: store, category: category, change: change)
        redirect_to number_path(id: params[:id]), notice: "Thanks for your feedback!"

    end

    
end
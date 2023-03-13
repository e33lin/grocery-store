class HomeController < ApplicationController
    def show
        found_unique_id = false
        until found_unique_id do
            new_session_id = rand(100001) # generates a random number between 0-100000
            if(List.find_by(list_id: new_session_id).blank?)
                # if user already has used the app, it keeps the same ID. if its a user's first time, we assign them an ID
                # pro: keeps user history
                # con: this app would never scale 
                session[:current_user_id] ||= new_session_id 
                found_unique_id = true # breaks the loop
            end
        end

        # purge all lists and recommendations created in the last week
        date = DateTime.now()
        range = (date - 7.days)..(date - 1.day)
        for x in List.where(created_at: range)
            x.destroy
        end
        for x in Recommendation.where(created_at: range)
            x.destroy
        end
    end
end
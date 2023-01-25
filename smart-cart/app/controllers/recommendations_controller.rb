class RecommendationsController < ApplicationController
    def show
        require 'json'
        l = ['milk', 'eggs']
        result = `python3 #{ENV["PWD"] + "/app/controllers/print_dict.py"} "'#{l}'"` # pass l as an argument 
        $hash = JSON.parse(result.gsub("'", "\"")) # turn string result into a hash
        #$first_list = hash['1']['list']
    end

    def number
    end
end
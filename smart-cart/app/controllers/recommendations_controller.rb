class RecommendationsController < ApplicationController
    def show
        require 'json'
        l = ['milk', 'eggs']
        result = `python3 #{ENV["PWD"] + "/app/controllers/print_dict.py"} "'#{l}'"` # pass l as an argument 
        $hash = JSON.parse(result.gsub("'", "\"")) # turn string result into a hash
        @hello = "hello"
        print $hash
        $stores = [$hash['1']['store'], $hash['2']['store'], $hash['3']['store']]
    end

    def number
        print "here is the print"
        print "'#{params[:id]}'"
        print "'#{params[:query]}'"
        #$store_name = @hash[["'#{params[:id]}'"]['store']]
    end
end
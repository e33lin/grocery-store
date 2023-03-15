class FeedbackController < ApplicationController
    def show
    end

    def create
    end

    def new
        @feedback = Feedback.new
    end
end
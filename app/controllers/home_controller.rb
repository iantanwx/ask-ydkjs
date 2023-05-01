# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @home_props = { question: 'What is YDKJS about?' }
  end
end

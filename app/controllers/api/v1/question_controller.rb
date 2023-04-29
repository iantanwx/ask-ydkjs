class Api::V1::QuestionController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    puts "question: #{question}"
    render json: { status: 'success' }
  end

  private

  def question
    params.require(:question)
  end
end

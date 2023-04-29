require 'csv'
require 'openai'
require 'dotenv/load'
require 'matrix'

class Api::V1::QuestionController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    puts "question: #{question}"
    embeddings_path = File.join(Rails.root, 'app', 'assets', 'data', 'ydkjs.pdf.embeddings.csv')
    embeddings = CSV.read(embeddings_path).drop(1)
    openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = openai_client.embeddings(parameters: {
                                          model: 'text-search-curie-query-001',
                                          input: question
                                        })
    query_embedding = Vector.elements(response.dig('data', 0, 'embedding'))

    dotted = embeddings.map do |row|
      doc_embedding = Vector.elements(row[3..-1].map(&:to_f))
      dot_product = doc_embedding.inner_product(query_embedding)
      { text: row[1], dot_product: }
    end
    sorted = dotted.sort_by { |row| -row[:dot_product] }
    render json: { status: 'success', text: sorted[0][:text] }
  end

  private

  def question
    params.require(:question)
  end
end

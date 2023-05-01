require 'csv'
require 'openai'
require 'dotenv/load'
require 'matrix'
require 'resemble'

Resemble.api_key = ENV['RESEMBLE_API_KEY']
MAX_SECTION_LEN = 500
SEPARATOR = "\n* "
SEPARATOR_LEN = 3

class Api::V1::QuestionController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    puts "question: #{question}"
    existing_question = Question.find_by(question:)
    if existing_question
      puts "found existing question: #{existing_question}"
      render json: { status: 'success', id: existing_question.id, question: existing_question.question,
                     answer: existing_question.answer }
      return
    end

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
      { text: row[1], tokens: row[2].to_i, dot_product: }
    end

    sorted = dotted.sort_by { |row| -row[:dot_product] }
    completion, context = get_completion(question, sorted)
    puts "completion: #{completion}"
    # TODO: add this back when Resemble lets us generate sync clips
    # voice = generate_voice(completion)
    question_record = Question.new(question:, answer: completion, context:)
    question_record.save

    render json: { status: 'success', id: question_record.id, question:, answer: completion }
  end

  private

  def construct_prompt(question, sorted_embeddings)
    chosen_sections = []
    chosen_sections_len = 0

    sorted_embeddings.each do |doc|
      chosen_sections_len += doc[:tokens] + SEPARATOR_LEN
      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length
        chosen_sections.append(
          SEPARATOR + doc[:text].slice(0...space_left)
        )
        break
      end
      chosen_sections.append(SEPARATOR + doc[:text])
    end

    header = "Kyle Simpson is a JavaScript developer and the author of the You Don't Know JS (YDKJS) series of books. These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from You Don't Know JS:\n"

    question_1 = "\n\n\nQ: What is function scope in JavaScript?\n\nA: In JavaScript, function scope refers to the visibility and lifetime of variables and functions within a particular function. Variables and functions declared within a function are only accessible within that function and are not visible to code outside of it. This helps prevent naming conflicts and provides a way to encapsulate functionality."
    question_2 = "\n\n\nQ: What is variable hoisting?\n\nA: Variable hoisting is a mechanism in JavaScript that moves variable declarations to the top of the scope. This means that a variable can be declared after it has been used. This is a common source of confusion for developers who are new to JavaScript."
    question_3 = "\n\n\nQ: What is the difference between == and ===?\n\nA: The == operator compares two values for equality. If the two values are of different types, JavaScript will attempt to convert them to the same type before comparing them. The === operator compares two values for equality. If the two values are of different types, they are considered unequal. This is a common source of confusion for developers who are new to JavaScript."
    question_4 = "\n\n\nQ: What is the difference between null and undefined?\n\nA: Null is a special value that represents the absence of a value. Undefined is a special value that represents the absence of a value. Null is a special value that represents the absence of a value. Undefined is a special value that represents the absence of a value."
    question_5 = "\n\n\nQ: What is a callback?\n\nA: A callback is a function that is passed as an argument to another function. The callback function is called at some point in the future, usually when an asynchronous operation has completed. Callbacks are a common way to handle asynchronous operations in JavaScript."
    question_6 = "\n\n\nQ: What is the event loop?\n\nA: The event loop is a mechanism that allows JavaScript to handle asynchronous operations. It is a queue of tasks that are waiting to be executed. When the call stack is empty, the event loop will take the first task from the queue and execute it. This process continues until the queue is empty."
    question_7 = "\n\n\nQ: What is the Object type?\n\nA: The Object type is the root of the JavaScript object hierarchy. All other types inherit from this type. The Object type has a number of methods that are inherited by all other types. These methods are used to perform common operations on objects."
    question_8 = "\n\n\nQ: What is prototype inheritance?\n\nA: Prototype inheritance is a mechanism that allows objects to inherit properties and methods from other objects. When an object is created, it inherits properties and methods from its prototype. When a property or method is accessed on an object, JavaScript will first look for it on the object itself. If it is not found, it will look for it on the object's prototype. This process continues until the property or method is found or the prototype chain is exhausted."
    question_9 = "\n\n\nQ: What is `this`?\n\nA: The this keyword refers to the object that is executing the current function. It is a special keyword that is automatically defined in every function. The value of this depends on how the function is called."
    question_10 = "\n\n\nQ: What is the difference between call and apply?\n\nA: The call method calls a function with a given this value and arguments provided individually. The apply method calls a function with a given this value and arguments provided as an array."

    [
      header + chosen_sections.join + question_1 + question_2 + question_3 + question_4 + question_5 + question_6 + question_7 + question_8 + question_9 + question_10 + "\n\n\nQ: " + question + "\n\nA: ",
      chosen_sections.join
    ]
  end

  def get_completion(question, embeddings)
    prompt, context = construct_prompt(question, embeddings)
    openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = openai_client.completions(parameters: {
                                           model: 'text-davinci-003',
                                           prompt:,
                                           max_tokens: 150
                                         })
    [response.dig('choices', 0, 'text'), context]
  end

  def generate_voice(_answer)
    project_uuid = '39071f2b'
    voice_uuid = '7e1f63e7'

    response = Resemble::V2::Clip.create_sync(
      project_uuid,
      voice_uuid,
      question,
      title: nil,
      sample_rate: nil,
      output_format: nil,
      precision: nil,
      include_timestamps: nil,
      is_public: nil,
      is_archived: nil,
      raw: nil
    )

    puts "response: #{response}"

    response['item']['audio_src_url']
  end

  def question
    params.require(:question)
  end
end

class Question < ApplicationRecord
  validates :question, presence: true, length: { maximum: 140 }
  validates :context, length: { maximum: 65_535 }
  validates :answer, length: { maximum: 1000 }
  # attribute :audio_src_url, :string, default: ''
end

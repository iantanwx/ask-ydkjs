class RemoveAudioSrcFromQuestions < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :audio_src_url, :string
  end
end

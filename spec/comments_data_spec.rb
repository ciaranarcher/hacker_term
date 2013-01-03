require 'hacker_term/comments_data'

module HackerTerm
  describe CommentsData do
    describe 'formatting' do

      it 'creates an array of comments' do
        comments = CommentsData.new File.read './data/comments.json'
        comments.data.should be_instance_of Hash
      end
    end
  end
end
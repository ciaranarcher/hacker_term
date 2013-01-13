require 'hacker_term/comments_data'

module HackerTerm
  describe CommentsData do
    describe 'format JSON' do
      let(:many_comments) { File.read './data/comments.json' }
      let(:lorem) { File.read './data/lorem.txt'}
      let(:single_comment) do
        '{
            "items":[
              {
                "username":"tghw",
                "comment":"Looking through &amp; hi there. __BR__",
                "id":"5003378",
                "grayedOutPercent":0,
                "reply_id":"5003378&amp;whence=%69%74%65%6d%3f%69%64%3d%35%30%30%32%39%37%34",
                "time":"3 hours ago",
                "children":[

                ]
              }
            ]
          }'
      end

      it 'creates an array of comments' do
        comments = CommentsData.new many_comments
        comments.data.should be_instance_of Array
      end

      it 'removes HTML entities' do
        data = single_comment

        comments = CommentsData.new data
        comments.data.first['comment'].should_not match /&amp;/ 
      end

      it 'replaces __BR__ entities' do
        data = single_comment

        comments = CommentsData.new data
        comments.data.first['comment'].should match /\n\n/ 
      end

      it '#fit_words_to_width splits a long line into fixed width lines preserving words' do
        comments = CommentsData.new
        comments.fit_words_to_width(lorem.split(' '), 80).split("\n").length.should == 8
      end

      it '#data_as_text splits words into fixed width columns' do
        comments = CommentsData.new many_comments
        comments.data_as_text(80).should be_instance_of String
      end



      it '#each returns a Hash representing a comment with username, comment and time filled' do
        comments = CommentsData.new many_comments
        comments.each do |c|
          c.should be_instance_of Hash
          c.should have_key :comment
          c.should have_key :username
          c.should have_key :time
        end
      end

      pending 'recursively formats a set of comments and replies' do
        comments = CommentsData.new many_comments
        # p comments
      end
    end
  end
end
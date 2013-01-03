require 'hacker_term/comments_data'

module HackerTerm
  describe CommentsData do
    describe 'formatting' do

      it 'creates an array of comments' do
        comments = CommentsData.new File.read './data/comments.json'
        p comments.data
        comments.data.should be_instance_of Array
      end

      it 'removes HTML entities' do
        data = '{
                  "items":[
                    {
                      "username":"tghw",
                      "comment":"Looking through &amp; hi there.",
                      "id":"5003378",
                      "grayedOutPercent":0,
                      "reply_id":"5003378&amp;whence=%69%74%65%6d%3f%69%64%3d%35%30%30%32%39%37%34",
                      "time":"3 hours ago",
                      "children":[

                      ]
                    }
                  ]
                }'

        comments = CommentsData.new data
        comments.data.first['comment'].should_not match /&amp;/ 
      end
    end
  end
end
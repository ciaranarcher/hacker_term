require 'hacker_term'

module HackerTerm

  describe PageData do
    it 'adds missing nodes' do
      data = '{"items":[{
           "title":"NextId",
           "url":"/news2",
           "description":"hn next id news2 "
        }]
      }'

      pd = PageData.new data
      pd.data.first.should have_key 'score'
    end
  end
end

require 'hacker_term'

module HackerTerm
  describe PageData do
    describe 'replace missing nodes' do
      before(:each) do
        @data = '{"items":[{
             "title":"NextId",
             "url":"/news2",
             "description":"hn next id news2 "
          }]
        }'
        @pd = PageData.new @data
      end

      it 'adds score node' do
        @pd.data.first.should have_key 'score'
      end

      pending 'adds comments node' do
      end
    end
  end
end

require 'hacker_term'

module HackerTerm
  describe PageData do
    describe 'replace missing nodes and format numbers' do
      before(:each) do
        @data = 
        '{"items":[
          {
           "title":"NextId",
           "url":"/news2",
           "description":"hn next id news2 "
          },
          {
           "title":"Ray Kurzweil joins Google",
           "url":"http://www.kurzweilai.net/kurzweil-joins-google-to-work-on-new-projects-involving-machine-learning-and-language-processing?utm_source=twitterfeed&utm_medium=twitter",
           "score":"260 points",
           "user":"dumitrue",
           "comments":"122 comments",
           "time":"14 hours ago",
           "item_id":"4923914",
           "description":"260 points by dumitrue 14 hours ago  | 122 comments"
          }
        ]}'
        @pd = PageData.new @data
      end

      it 'adds score node' do
        @pd.data.first.should have_key 'score'
      end

      it 'adds comments node' do
        @pd.data.first.should have_key 'comments'
      end

      it 'formats score node as a number' do
        @pd.data.last['score'].is_num?.should be_true
      end

    end
    describe 'calculating stats' do
      before(:each) do
        @page_data = HackerTerm::PageData.new File.read './data/data.json' 
      end

      pending 'provides a mean' do

      end

      pending 'provides a median' do
      end

      pending 'provides a mode' do
      end
    end
  end
end

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

      it 'formats score node as a number when the node didn\'t exist' do
        @pd.data.first['score'].should == '0'
      end

      it 'formats score node as a number when text is present' do
        @pd.data.last['score'].should == '260'
      end

      it 'formats comments node as a number when the node didn\'t exist' do
        @pd.data.first['comments'].should == '0'
      end

      it 'formats comments node as a number when text is present' do
        @pd.data.last['comments'].should == '122'
      end

    end
    describe 'calculating stats' do
      before(:each) do
        @page_data = HackerTerm::PageData.new File.read './data/data.json' 
      end

      it 'provides a mean' do
        @page_data.mean_score.should == 194.19354838709677
      end

      it 'provides a median' do
        @page_data.median_score.should == 131
      end

      pending 'provides a mode' do
      end
    end
  end
end

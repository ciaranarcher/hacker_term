require 'hacker_term/page_data'

module HackerTerm
  describe PageData do
    describe 'formatting JSON' do
      before(:each) do
        @data =
        '{"items":[
          {
           "title":"NextId",
           "url":"/news2",
           "description":"hn next id news2 "
          },
          {
           "title":"Ray Kurzweil joins Google &amp;",
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
        expect(@pd.data.first).to have_key 'score'
      end

      it 'adds comments node' do
        expect(@pd.data.first).to have_key 'comments'
      end

      it 'formats score node as a number when the node didn\'t exist' do
        expect(@pd.data.first['score']).to be == '0'
      end

      it 'formats score node as a number when text is present' do
        expect(@pd.data.last['score']).to be == '260'
      end

      it 'formats comments node as a number when the node didn\'t exist' do
        expect(@pd.data.first['comments']).to be == '0'
      end

      it 'formats comments node as a number when text is present' do
        expect(@pd.data.last['comments']).to be == '122'
      end

      it 'unescapes HTML entities in title where present' do
        expect(@pd.data.last['title']).to_not match /&amp;/
      end
    end

    describe 'calculating stats' do
      before(:each) do
        @page_data = PageData.new File.read './data/data.json'
      end

      it 'provides a mean' do
        expect(@page_data.mean_score).to be == 193.59375
      end

      it 'provides a median' do
        expect(@page_data.median_score).to be == 135.0
      end

      it 'provides a mode' do
        expect(@page_data.mode_score).to be == 0
      end
    end

    describe 'formatting URLs' do
      before(:each) do
        @pg = PageData.new File.read './data/data.json'
      end

      it 'provides a URL for actual article' do
        expect(@pg.selected_url).to be == "http://powwow.cc/"
      end

      it 'provides a URL for article comments' do
        expect(@pg.selected_comments_url).to be == "http://news.ycombinator.com/item?id=4924763"
      end

      it 'links to HN directly if URL is not absolute' do
        expect(@pg.data.last['url']).to be == 'http://news.ycombinator.com/item?id=4992617'
      end
    end

    describe 'sorting' do
      before(:each) do
        @data =
        '{"items":[
          {
           "title":"First Article",
           "url":"http://google.com",
           "score":"0 points",
           "user":"dumitrue",
           "comments":"100 comments",
           "time":"14 hours ago",
           "item_id":"4923914",
           "description":"260 points by dumitrue 14 hours ago  | 122 comments"
          },
          {
          "title":"Second Article",
           "url":"http://google.com",
           "score":"50 points",
           "user":"dumitrue",
           "comments":"5 comments",
           "time":"14 hours ago",
           "item_id":"4923914",
           "description":"260 points by dumitrue 14 hours ago  | 122 comments"
          },
          {
           "title":"Third Article",
           "url":"http://google.com",
           "score":"25 points",
           "user":"dumitrue",
           "comments":"0 comments",
           "time":"14 hours ago",
           "item_id":"4923914",
           "description":"260 points by dumitrue 14 hours ago  | 122 comments"
          }
        ]}'
        @pd = PageData.new @data
      end

      it 'preserves natural ordering as default' do
        expect(@pd.data.first['title']).to be == 'First Article'
        expect(@pd.data.last['title']).to be == 'Third Article'
      end

      it 'sorts by score when requested' do
        @pd.sort_on!(:score)
        expect(@pd.data.first['title']).to be == 'Second Article'
        expect(@pd.data.last['title']).to be == 'First Article'
      end

      it 'sorts by number of comments when requested' do
        @pd.sort_on!(:comments)
        expect(@pd.data.first['title']).to be == 'First Article'
        expect(@pd.data.last['title']).to be == 'Third Article'
      end

      it 'sorts by rank when requested' do
        @pd.sort_on!(:rank)
        expect(@pd.data.first['title']).to be == 'First Article'
        expect(@pd.data.last['title']).to be == 'Third Article'
      end

      it 'sorts by title when requested' do
        @pd.sort_on!(:title)
        expect(@pd.data.first['title']).to be == 'First Article'
        expect(@pd.data.last['title']).to be == 'Third Article'
      end

      it 're-sorts by rank when requested' do
        @pd.sort_on!(:comments)
        @pd.sort_on!(:rank)
        expect(@pd.data.first['title']).to be == 'First Article'
        expect(@pd.data.last['title']).to be == 'Third Article'
      end
    end
  end
end

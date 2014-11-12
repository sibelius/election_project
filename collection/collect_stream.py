class StreamListener(tweepy.StreamListener):
    ''' This class listen to new tweets '''
    def __init__(self):
        super(StreamListener, self).__init__()

        # The eagleEye class process the tweets
        self.eagle_eye = EagleEye()

    def on_data(self, raw_data):
        ''' Handle the tweet data '''
        try:
            tweet = json.loads(str(raw_data))
            self.eagle_eye.process_tweet(tweet)

        except:
            print 'Data writting exception.'


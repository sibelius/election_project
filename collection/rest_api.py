#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
'''

import datetime  # python datetime module
import json      # python json module
import os        # python os module, used for creating folders
import sys
import time
import twitter

reload(sys)
sys.setdefaultencoding("utf-8")

consumer_key = '9JKChCx3ePL2m2KLeL98HQ'
consumer_secret = 'rtMbPwidDXXUXEcqlfnb2QiBEeIllH2Hq30dq92Af58'
access_token_key = '2313873457-9S4sFypeD6OVY5IAtx1e7R64h5Po0zFiWM3X0Xp'
access_token_secret = 'HK5ZhGI2FMzjKs2mzx9Mgs6Tq4uYDgzFzI0gOsUevZagh'
output_folder = 'data/{0}' # the fold stores crawl-down data

myApi=twitter.Api(consumer_key=consumer_key, \
        consumer_secret=consumer_secret, \
        access_token_key=access_token_key, \
        access_token_secret=access_token_secret)


def query_tweets_related_elections():
    keywords = ['aécio', 'aecio', '#aecio', 'dilma', '#dilma', 'rousseff', 'pt', '#pt', 'psdb', '#psdb', '#eleicoes', '#Eleicoes2014']

    query = '(' + ' OR '.join(keywords) + ')'

    MAX_ID = None
    tweets = []
    K = 18
    count = 0;

    while True:
        try:
            output_folder_date = output_folder.format(datetime.datetime.now().strftime('%Y_%m_%d'))
            if not os.path.exists(output_folder_date): os.makedirs(output_folder_date)

            output_file = output_folder_date+'/rest_elections.txt'

            for it in range(K): # Retrieve up to K * 100 tweets
                temp_tweets = [json.loads(str(raw_tweet)) for raw_tweet \
                    in myApi.GetSearch(query, count = 100, lang='pt',
                    max_id = MAX_ID)]#, result_type='recent')]

                f = open(output_file, 'a+')
                for t in temp_tweets:
                    f.write(json.dumps(t) + '\n')
                f.close()

                count = count + len(temp_tweets)

                if temp_tweets:
                    MAX_ID = temp_tweets[-1]['id']
            print('Tweets retrieved: %d' % count)
            time.sleep(15 * 60)
        except:
            print 'Exception occur!'
            break

def main():
    query_tweets_related_elections();

if __name__ == '__main__':
    main()




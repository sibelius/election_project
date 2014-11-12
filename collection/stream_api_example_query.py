#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
'''

import tweepy    # twitter api module - python version
import datetime  # python datetime module
import json      # python json module
import os        # python os module, used for creating folders
import sys

reload(sys)
sys.setdefaultencoding("utf-8")

consumer_key = '9JKChCx3ePL2m2KLeL98HQ'
consumer_secret = 'rtMbPwidDXXUXEcqlfnb2QiBEeIllH2Hq30dq92Af58'
access_token_key = '2313873457-9S4sFypeD6OVY5IAtx1e7R64h5Po0zFiWM3X0Xp'
access_token_secret = 'HK5ZhGI2FMzjKs2mzx9Mgs6Tq4uYDgzFzI0gOsUevZagh'
output_folder = 'data/{0}' # the fold stores crawl-down data
OAuth = tweepy.OAuthHandler(consumer_key, consumer_secret)
OAuth.set_access_token(access_token_key, access_token_secret)

class StreamListener(tweepy.StreamListener):
     def __init__(self):
         self.count = 0

     def on_data(self, raw_data):
         output_folder_date = output_folder.format(datetime.datetime.now().strftime('%Y_%m_%d'))
         if not os.path.exists(output_folder_date): os.makedirs(output_folder_date)
         output_file = output_folder_date+'/elections.txt'
         try:
             jdata = json.loads(str(raw_data))
             f = open(output_file, 'a+')
             f.write(json.dumps(jdata) + '\n')
             f.close()
             self.count = self.count + 1
             print('Tweets Retrieved: %d' % self.count)
         except Exception as e:
             print 'Data writting exception'

def main():
    while True:
        try:
            sl = StreamListener()
            stream = tweepy.Stream(OAuth, sl)

            keywords = ['aécio', 'aecio', '#aecio', 'dilma', '#dilma', 'rousseff', 'pt', '#pt', 'psdb', '#psdb', '#eleicoes', '#Eleicoes2014']

            stream.filter(track = keywords, languages = ['pt'])
            #stream.filter(track = ['car crash', 'road congestion', 'highway', 'pedestrain'])
        except:
            print 'Exception occur!'
            break

if __name__ == '__main__':
    main()




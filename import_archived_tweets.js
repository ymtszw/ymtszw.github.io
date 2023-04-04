/**
 * Must be run as: npx import_archived_tweets <path-to-archived-tweets-js-file>
 */

window = { YTD: { tweets: {} } };

// require archived tweets js file
require(process.argv[2]);

// list available parts under window.YTD.tweets
const parts = Object.keys(window.YTD.tweets);
console.log("Available parts:", parts);
const tweets = parts.flatMap((part) => window.YTD.tweets[part]);
console.log("Enumerated tweets:", tweets.length);

const myAvatarUrl20230405 =
  "https://pbs.twimg.com/profile_images/1520432647868391430/4b2AUYjC_normal.jpg";
const placeholderAvatarUrl =
  "https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png";

const simplifiedTweets = tweets.map(function (tweet) {
  let simplified = {
    CreatedAt: tweet.tweet.created_at,
    Text: tweet.tweet.full_text,
    StatusId: tweet.tweet.id,
    UserName: "Gada / ymtszw",
    UserProfileImageUrl: myAvatarUrl20230405,
  };

  destructivelyResolveExtendedEntitiesMedia(simplified, tweet.tweet);
  destructivelyResolveRetweet(simplified, tweet.tweet);
  return simplified;
});

function destructivelyResolveExtendedEntitiesMedia(simplified, tweet) {
  if (tweet.extended_entities?.media?.length > 0) {
    // OptimizedDecoder.succeed (List.map4 Media)
    // |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
    // |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
    // |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
    // |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
    simplified.ExtendedEntitiesMediaUrls =
      tweet.extended_entities?.media?.map((media) => media.url)?.join(",") ||
      "";
    simplified.ExtendedEntitiesMediaSourceUrls =
      tweet.extended_entities?.media
        ?.map((media) => media.media_url_https)
        ?.join(",") || "";
    simplified.ExtendedEntitiesMediaTypes =
      tweet.extended_entities?.media?.map((media) => media.type)?.join(",") ||
      "";
    simplified.ExtendedEntitiesMediaExpandedUrls =
      tweet.extended_entities?.media
        ?.map((media) => media.expanded_url)
        ?.join(",") || "";
  }
}

function destructivelyResolveRetweet(simplified, tweet) {
  const rtPattern = /(RT @([^:]+?): )/;
  // check full_text against rtPattern and capture sub-matches
  if (tweet.full_text.match(rtPattern)) {
    const [_, rtPrefix, rtUserName] = tweet.full_text.match(rtPattern);
    simplified.Retweeted = "TRUE";
    simplified.RetweetedStatusFullText = tweet.full_text.replace(rtPrefix, "");
    // set retweeted status id; sadly we cannot get original tweet ID here, only "retweet" ID is available
    simplified.RetweetedStatusId = tweet.id;
    simplified.RetweetedStatusUserName =
      tweet.entities?.user_mentions?.find(
        (user_mention) => user_mention.screen_name === rtUserName
      )?.name || rtUserName; // if display_name is changed, we can no longer track author name
    simplified.RetweetedStatusUserProfileImageUrl = placeholderAvatarUrl;
  } else {
    simplified.Retweeted = "FALSE";
  }
}

// console.log("Example 0:", simplifiedTweets[0]);
// console.log("Example 10:", simplifiedTweets[10]);
// console.log("Example 50:", simplifiedTweets[50]);
// console.log("Example 100:", simplifiedTweets[100]);
// console.log("Example 200:", simplifiedTweets[200]);
// console.log("Example 300:", simplifiedTweets[300]);
// console.log("Example 400:", simplifiedTweets[400]);
// console.log("Example 500:", simplifiedTweets[500]);
// console.log("Example 600:", simplifiedTweets[600]);
// console.log("Example 700:", simplifiedTweets[700]);
// console.log("Example 800:", simplifiedTweets[800]);
// console.log("Example 900:", simplifiedTweets[900]);
// console.log("Example 1000:", simplifiedTweets[1000]);
// console.log("Example 5000:", simplifiedTweets[5000]);
// console.log("Example 10000:", simplifiedTweets[10000]);
// console.log("Example 20000:", simplifiedTweets[20000]);

/*

required archive tweet js file must look like this:

    window.YTD.tweets.part0 = [
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1642304241921572864"
              ],
              "editableUntil" : "2023-04-01T23:43:38.468Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"http://twitter.com/#!/download/ipad\" rel=\"nofollow\">Twitter for iPad</a>",
          "entities" : {
            "hashtags" : [ ],
            "symbols" : [ ],
            "user_mentions" : [
              {
                "name" : "mizchi",
                "screen_name" : "mizchi",
                "indices" : [
                  "3",
                  "10"
                ],
                "id_str" : "14407731",
                "id" : "14407731"
              }
            ],
            "urls" : [ ]
          },
          "display_text_range" : [
            "0",
            "140"
          ],
          "favorite_count" : "0",
          "id_str" : "1642304241921572864",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1642304241921572864",
          "created_at" : "Sat Apr 01 23:13:38 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @mizchi: 俺も node.js v0.2.0 から見てたから今使えてる感あるので、黎明期で筋がいいもの見つけて一緒に成長するのが他者と比べて一番差をつけやすいと思う。ただ見極めがムズい。ChatGPT は当たりだと思うが... / “今、ChatGPTの使い方を学…",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1642303752848961536"
              ],
              "editableUntil" : "2023-04-01T23:41:41.864Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"http://twitter.com/#!/download/ipad\" rel=\"nofollow\">Twitter for iPad</a>",
          "entities" : {
            "hashtags" : [ ],
            "symbols" : [ ],
            "user_mentions" : [
              {
                "name" : "ジェット・リョー",
                "screen_name" : "ikazombie",
                "indices" : [
                  "3",
                  "13"
                ],
                "id_str" : "174704548",
                "id" : "174704548"
              }
            ],
            "urls" : [ ]
          },
          "display_text_range" : [
            "0",
            "140"
          ],
          "favorite_count" : "0",
          "id_str" : "1642303752848961536",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1642303752848961536",
          "created_at" : "Sat Apr 01 23:11:41 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @ikazombie: クトゥルフ漁業生活アドベンチャー『DREDGE』、おもしろい！日没と共に怪異が蠢き出す呪われた海域で、正気を保ちながら漁師として生計を立てる。釣れば釣るほど「釣っちゃいけないタイプの生き物」で魚図鑑が埋まっていくのも楽しい。PS/XBOX/Swit…",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1642132538008408065"
              ],
              "editableUntil" : "2023-04-01T12:21:21.065Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://about.twitter.com/products/tweetdeck\" rel=\"nofollow\">TweetDeck</a>",
          "entities" : {
            "user_mentions" : [
              {
                "name" : "「たま」という船に乗っていた",
                "screen_name" : "EhBHy9Jb1zrua58",
                "indices" : [
                  "3",
                  "19"
                ],
                "id_str" : "1168098323544150016",
                "id" : "1168098323544150016"
              }
            ],
            "urls" : [ ],
            "symbols" : [ ],
            "media" : [
              {
                "expanded_url" : "https://twitter.com/EhBHy9Jb1zrua58/status/1642127697680924672/photo/1",
                "source_status_id" : "1642127697680924672",
                "indices" : [
                  "84",
                  "107"
                ],
                "url" : "https://t.co/uHWlvKSKbE",
                "media_url" : "http://pbs.twimg.com/media/FsoCbzuaQAAmQPU.jpg",
                "id_str" : "1642127690894557184",
                "source_user_id" : "1168098323544150016",
                "id" : "1642127690894557184",
                "media_url_https" : "https://pbs.twimg.com/media/FsoCbzuaQAAmQPU.jpg",
                "source_user_id_str" : "1168098323544150016",
                "sizes" : {
                  "medium" : {
                    "w" : "857",
                    "h" : "1200",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "1462",
                    "h" : "2048",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "485",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "source_status_id_str" : "1642127697680924672",
                "display_url" : "pic.twitter.com/uHWlvKSKbE"
              }
            ],
            "hashtags" : [
              {
                "text" : "エイプリルフール",
                "indices" : [
                  "67",
                  "76"
                ]
              },
              {
                "text" : "四月馬鹿",
                "indices" : [
                  "78",
                  "83"
                ]
              }
            ]
          },
          "display_text_range" : [
            "0",
            "107"
          ],
          "favorite_count" : "0",
          "id_str" : "1642132538008408065",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1642132538008408065",
          "possibly_sensitive" : false,
          "created_at" : "Sat Apr 01 11:51:21 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @EhBHy9Jb1zrua58: こちら、知久さんと犬のかがやきさんのコラボ\n『知久のとしやき』がシークレットとなってます🤣\n#エイプリルフール \n#四月馬鹿 https://t.co/uHWlvKSKbE",
          "lang" : "ja",
          "extended_entities" : {
            "media" : [
              {
                "expanded_url" : "https://twitter.com/EhBHy9Jb1zrua58/status/1642127697680924672/photo/1",
                "source_status_id" : "1642127697680924672",
                "indices" : [
                  "84",
                  "107"
                ],
                "url" : "https://t.co/uHWlvKSKbE",
                "media_url" : "http://pbs.twimg.com/media/FsoCbzuaQAAmQPU.jpg",
                "id_str" : "1642127690894557184",
                "source_user_id" : "1168098323544150016",
                "id" : "1642127690894557184",
                "media_url_https" : "https://pbs.twimg.com/media/FsoCbzuaQAAmQPU.jpg",
                "source_user_id_str" : "1168098323544150016",
                "sizes" : {
                  "medium" : {
                    "w" : "857",
                    "h" : "1200",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "1462",
                    "h" : "2048",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "485",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "source_status_id_str" : "1642127697680924672",
                "display_url" : "pic.twitter.com/uHWlvKSKbE"
              },
              {
                "expanded_url" : "https://twitter.com/EhBHy9Jb1zrua58/status/1642127697680924672/photo/1",
                "source_status_id" : "1642127697680924672",
                "indices" : [
                  "84",
                  "107"
                ],
                "url" : "https://t.co/uHWlvKSKbE",
                "media_url" : "http://pbs.twimg.com/media/FsoCcE4aYAAY7TU.jpg",
                "id_str" : "1642127695499911168",
                "source_user_id" : "1168098323544150016",
                "id" : "1642127695499911168",
                "media_url_https" : "https://pbs.twimg.com/media/FsoCcE4aYAAY7TU.jpg",
                "source_user_id_str" : "1168098323544150016",
                "sizes" : {
                  "small" : {
                    "w" : "471",
                    "h" : "680",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "medium" : {
                    "w" : "831",
                    "h" : "1200",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "1418",
                    "h" : "2048",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "source_status_id_str" : "1642127697680924672",
                "display_url" : "pic.twitter.com/uHWlvKSKbE"
              }
            ]
          }
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1642033440412561409"
              ],
              "editableUntil" : "2023-04-01T05:47:34.357Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"http://twitter.com/#!/download/ipad\" rel=\"nofollow\">Twitter for iPad</a>",
          "entities" : {
            "user_mentions" : [
              {
                "name" : "正気・腕力・犬",
                "screen_name" : "tsukimikaze774",
                "indices" : [
                  "3",
                  "18"
                ],
                "id_str" : "215801874",
                "id" : "215801874"
              }
            ],
            "urls" : [ ],
            "symbols" : [ ],
            "media" : [
              {
                "expanded_url" : "https://twitter.com/tsukimikaze774/status/1641959110311837696/video/1",
                "source_status_id" : "1641959110311837696",
                "indices" : [
                  "47",
                  "70"
                ],
                "url" : "https://t.co/6oaOKcBt7M",
                "media_url" : "http://pbs.twimg.com/ext_tw_video_thumb/1641959046466146304/pu/img/S7Za-HcLLpbY-9QB.jpg",
                "id_str" : "1641959046466146304",
                "source_user_id" : "215801874",
                "id" : "1641959046466146304",
                "media_url_https" : "https://pbs.twimg.com/ext_tw_video_thumb/1641959046466146304/pu/img/S7Za-HcLLpbY-9QB.jpg",
                "source_user_id_str" : "215801874",
                "sizes" : {
                  "medium" : {
                    "w" : "675",
                    "h" : "1200",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "720",
                    "h" : "1280",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "383",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "source_status_id_str" : "1641959110311837696",
                "display_url" : "pic.twitter.com/6oaOKcBt7M"
              }
            ],
            "hashtags" : [ ]
          },
          "display_text_range" : [
            "0",
            "70"
          ],
          "favorite_count" : "0",
          "id_str" : "1642033440412561409",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1642033440412561409",
          "possibly_sensitive" : false,
          "created_at" : "Sat Apr 01 05:17:34 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @tsukimikaze774: そんなわけでレッカーを待ちながら貝が歩くのとか見てる https://t.co/6oaOKcBt7M",
          "lang" : "ja",
          "extended_entities" : {
            "media" : [
              {
                "expanded_url" : "https://twitter.com/tsukimikaze774/status/1641959110311837696/video/1",
                "source_status_id" : "1641959110311837696",
                "indices" : [
                  "47",
                  "70"
                ],
                "url" : "https://t.co/6oaOKcBt7M",
                "media_url" : "http://pbs.twimg.com/ext_tw_video_thumb/1641959046466146304/pu/img/S7Za-HcLLpbY-9QB.jpg",
                "id_str" : "1641959046466146304",
                "video_info" : {
                  "aspect_ratio" : [
                    "9",
                    "16"
                  ],
                  "duration_millis" : "15368",
                  "variants" : [
                    {
                      "bitrate" : "950000",
                      "content_type" : "video/mp4",
                      "url" : "https://video.twimg.com/ext_tw_video/1641959046466146304/pu/vid/480x852/ZF91nc4_5PHmceVo.mp4?tag=12"
                    },
                    {
                      "content_type" : "application/x-mpegURL",
                      "url" : "https://video.twimg.com/ext_tw_video/1641959046466146304/pu/pl/7h3E-EiLpkEvnvyg.m3u8?tag=12&container=fmp4"
                    },
                    {
                      "bitrate" : "632000",
                      "content_type" : "video/mp4",
                      "url" : "https://video.twimg.com/ext_tw_video/1641959046466146304/pu/vid/320x568/Y5yvYXw7FfR7ccdI.mp4?tag=12"
                    },
                    {
                      "bitrate" : "2176000",
                      "content_type" : "video/mp4",
                      "url" : "https://video.twimg.com/ext_tw_video/1641959046466146304/pu/vid/720x1280/1y5GT5ntXbWKFekr.mp4?tag=12"
                    }
                  ]
                },
                "source_user_id" : "215801874",
                "additional_media_info" : {
                  "monetizable" : false
                },
                "id" : "1641959046466146304",
                "media_url_https" : "https://pbs.twimg.com/ext_tw_video_thumb/1641959046466146304/pu/img/S7Za-HcLLpbY-9QB.jpg",
                "source_user_id_str" : "215801874",
                "sizes" : {
                  "medium" : {
                    "w" : "675",
                    "h" : "1200",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "720",
                    "h" : "1280",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "383",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "video",
                "source_status_id_str" : "1641959110311837696",
                "display_url" : "pic.twitter.com/6oaOKcBt7M"
              }
            ]
          }
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641970224118534147"
              ],
              "editableUntil" : "2023-04-01T01:36:22.418Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"http://twitter.com/#!/download/ipad\" rel=\"nofollow\">Twitter for iPad</a>",
          "entities" : {
            "hashtags" : [ ],
            "symbols" : [ ],
            "user_mentions" : [
              {
                "name" : "立派プログラマ",
                "screen_name" : "no_maddo",
                "indices" : [
                  "3",
                  "12"
                ],
                "id_str" : "162717165",
                "id" : "162717165"
              }
            ],
            "urls" : [ ]
          },
          "display_text_range" : [
            "0",
            "61"
          ],
          "favorite_count" : "0",
          "id_str" : "1641970224118534147",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641970224118534147",
          "created_at" : "Sat Apr 01 01:06:22 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @no_maddo: 一ヶ月でサービス終了するソシャゲにも中で作っていた人がいるんだな、、、と思ったら泣いてしまった",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641928217559973888"
              ],
              "editableUntil" : "2023-03-31T22:49:27.000Z",
              "editsRemaining" : "5",
              "isEditEligible" : true
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://about.twitter.com/products/tweetdeck\" rel=\"nofollow\">TweetDeck</a>",
          "entities" : {
            "hashtags" : [ ],
            "symbols" : [ ],
            "user_mentions" : [ ],
            "urls" : [ ]
          },
          "display_text_range" : [
            "0",
            "38"
          ],
          "favorite_count" : "0",
          "id_str" : "1641928217559973888",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641928217559973888",
          "created_at" : "Fri Mar 31 22:19:27 +0000 2023",
          "favorited" : false,
          "full_text" : "よう見つけたな。\nこんくらいだと片っ端からGPTに食わせてけば見つかるのかな",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641928018477342720"
              ],
              "editableUntil" : "2023-03-31T22:48:39.809Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://about.twitter.com/products/tweetdeck\" rel=\"nofollow\">TweetDeck</a>",
          "entities" : {
            "hashtags" : [ ],
            "symbols" : [ ],
            "user_mentions" : [
              {
                "name" : "Yosuke Torii / ジンジャー",
                "screen_name" : "jinjor",
                "indices" : [
                  "3",
                  "10"
                ],
                "id_str" : "14205987",
                "id" : "14205987"
              }
            ],
            "urls" : [
              {
                "url" : "https://t.co/UasdG9bSQs",
                "expanded_url" : "https://github.com/twitter/the-algorithm/pull/362",
                "display_url" : "github.com/twitter/the-al…",
                "indices" : [
                  "30",
                  "53"
                ]
              }
            ]
          },
          "display_text_range" : [
            "0",
            "53"
          ],
          "favorite_count" : "0",
          "id_str" : "1641928018477342720",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641928018477342720",
          "possibly_sensitive" : false,
          "created_at" : "Fri Mar 31 22:18:39 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @jinjor: 普通にバグ修正の PR が来てるw\nhttps://t.co/UasdG9bSQs",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641927448374968320"
              ],
              "editableUntil" : "2023-03-31T22:46:23.000Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://mobile.twitter.com\" rel=\"nofollow\">Twitter Web App</a>",
          "entities" : {
            "user_mentions" : [ ],
            "urls" : [ ],
            "symbols" : [ ],
            "media" : [
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641927448374968320/photo/1",
                "indices" : [
                  "0",
                  "23"
                ],
                "url" : "https://t.co/G7WGxytF5r",
                "media_url" : "http://pbs.twimg.com/media/FslL_XHakAAV3qM.jpg",
                "id_str" : "1641927091062214656",
                "id" : "1641927091062214656",
                "media_url_https" : "https://pbs.twimg.com/media/FslL_XHakAAV3qM.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "510",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/G7WGxytF5r"
              }
            ],
            "hashtags" : [ ]
          },
          "display_text_range" : [
            "0",
            "23"
          ],
          "favorite_count" : "0",
          "in_reply_to_status_id_str" : "1641905232568541185",
          "id_str" : "1641927448374968320",
          "in_reply_to_user_id" : "352840258",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641927448374968320",
          "in_reply_to_status_id" : "1641905232568541185",
          "possibly_sensitive" : false,
          "created_at" : "Fri Mar 31 22:16:23 +0000 2023",
          "favorited" : false,
          "full_text" : "https://t.co/G7WGxytF5r",
          "lang" : "zxx",
          "in_reply_to_screen_name" : "gada_twt",
          "in_reply_to_user_id_str" : "352840258",
          "extended_entities" : {
            "media" : [
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641927448374968320/photo/1",
                "indices" : [
                  "0",
                  "23"
                ],
                "url" : "https://t.co/G7WGxytF5r",
                "media_url" : "http://pbs.twimg.com/media/FslL_XHakAAV3qM.jpg",
                "id_str" : "1641927091062214656",
                "id" : "1641927091062214656",
                "media_url_https" : "https://pbs.twimg.com/media/FslL_XHakAAV3qM.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "510",
                    "h" : "680",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/G7WGxytF5r"
              }
            ]
          }
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641905232568541185"
              ],
              "editableUntil" : "2023-03-31T21:18:07.000Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://about.twitter.com/products/tweetdeck\" rel=\"nofollow\">TweetDeck</a>",
          "entities" : {
            "user_mentions" : [ ],
            "urls" : [ ],
            "symbols" : [ ],
            "media" : [
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641905232568541185/photo/1",
                "indices" : [
                  "28",
                  "51"
                ],
                "url" : "https://t.co/IPGBBwkRfb",
                "media_url" : "http://pbs.twimg.com/media/Fsk3ZJkaYAYBtyc.jpg",
                "id_str" : "1641904444358156294",
                "id" : "1641904444358156294",
                "media_url_https" : "https://pbs.twimg.com/media/Fsk3ZJkaYAYBtyc.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  },
                  "small" : {
                    "w" : "680",
                    "h" : "510",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "large" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/IPGBBwkRfb"
              }
            ],
            "hashtags" : [ ]
          },
          "display_text_range" : [
            "0",
            "51"
          ],
          "favorite_count" : "0",
          "id_str" : "1641905232568541185",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641905232568541185",
          "possibly_sensitive" : false,
          "created_at" : "Fri Mar 31 20:48:07 +0000 2023",
          "favorited" : false,
          "full_text" : "オレオレTwilogを黙々と作ってたら会社で夜が明けた https://t.co/IPGBBwkRfb",
          "lang" : "ja",
          "extended_entities" : {
            "media" : [
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641905232568541185/photo/1",
                "indices" : [
                  "28",
                  "51"
                ],
                "url" : "https://t.co/IPGBBwkRfb",
                "media_url" : "http://pbs.twimg.com/media/Fsk3ZJkaYAYBtyc.jpg",
                "id_str" : "1641904444358156294",
                "id" : "1641904444358156294",
                "media_url_https" : "https://pbs.twimg.com/media/Fsk3ZJkaYAYBtyc.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  },
                  "small" : {
                    "w" : "680",
                    "h" : "510",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "large" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/IPGBBwkRfb"
              },
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641905232568541185/photo/1",
                "indices" : [
                  "28",
                  "51"
                ],
                "url" : "https://t.co/IPGBBwkRfb",
                "media_url" : "http://pbs.twimg.com/media/Fsk3hhYaYAc3cZs.jpg",
                "id_str" : "1641904588189229063",
                "id" : "1641904588189229063",
                "media_url_https" : "https://pbs.twimg.com/media/Fsk3hhYaYAc3cZs.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "small" : {
                    "w" : "510",
                    "h" : "680",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "768",
                    "h" : "1024",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/IPGBBwkRfb"
              },
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641905232568541185/photo/1",
                "indices" : [
                  "28",
                  "51"
                ],
                "url" : "https://t.co/IPGBBwkRfb",
                "media_url" : "http://pbs.twimg.com/media/Fsk34ElaYAASW8p.jpg",
                "id_str" : "1641904975596118016",
                "id" : "1641904975596118016",
                "media_url_https" : "https://pbs.twimg.com/media/Fsk34ElaYAASW8p.jpg",
                "sizes" : {
                  "medium" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  },
                  "large" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  },
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "small" : {
                    "w" : "680",
                    "h" : "510",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/IPGBBwkRfb"
              },
              {
                "expanded_url" : "https://twitter.com/gada_twt/status/1641905232568541185/photo/1",
                "indices" : [
                  "28",
                  "51"
                ],
                "url" : "https://t.co/IPGBBwkRfb",
                "media_url" : "http://pbs.twimg.com/media/Fsk4FdnaYAITbzh.jpg",
                "id_str" : "1641905205653692418",
                "id" : "1641905205653692418",
                "media_url_https" : "https://pbs.twimg.com/media/Fsk4FdnaYAITbzh.jpg",
                "sizes" : {
                  "thumb" : {
                    "w" : "150",
                    "h" : "150",
                    "resize" : "crop"
                  },
                  "large" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  },
                  "small" : {
                    "w" : "680",
                    "h" : "510",
                    "resize" : "fit"
                  },
                  "medium" : {
                    "w" : "1024",
                    "h" : "768",
                    "resize" : "fit"
                  }
                },
                "type" : "photo",
                "display_url" : "pic.twitter.com/IPGBBwkRfb"
              }
            ]
          }
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641902882101551104"
              ],
              "editableUntil" : "2023-03-31T21:08:46.830Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }
          },
          "retweeted" : false,
          "source" : "<a href=\"https://about.twitter.com/products/tweetdeck\" rel=\"nofollow\">TweetDeck</a>",
          "entities" : {
            "hashtags" : [
              {
                "text" : "キャンプ県",
                "indices" : [
                  "133",
                  "139"
                ]
              }
            ],
            "symbols" : [ ],
            "user_mentions" : [
              {
                "name" : "アニメ『ゆるキャン△』シリーズ公式【4/26 映画BD発売】",
                "screen_name" : "yurucamp_anime",
                "indices" : [
                  "3",
                  "18"
                ],
                "id_str" : "870547677364101120",
                "id" : "870547677364101120"
              }
            ],
            "urls" : [
              {
                "url" : "https://t.co/e8uwkrZnoW",
                "expanded_url" : "https://yurucamp.jp/camp-pref",
                "display_url" : "yurucamp.jp/camp-pref",
                "indices" : [
                  "109",
                  "132"
                ]
              }
            ]
          },
          "display_text_range" : [
            "0",
            "140"
          ],
          "favorite_count" : "0",
          "id_str" : "1641902882101551104",
          "truncated" : false,
          "retweet_count" : "0",
          "id" : "1641902882101551104",
          "possibly_sensitive" : false,
          "created_at" : "Fri Mar 31 20:38:46 +0000 2023",
          "favorited" : false,
          "full_text" : "RT @yurucamp_anime: 【緊急速報】\nこの度、山梨県は「キャンプ県」へと改名されました。\nまた『ゆるキャン△』より志摩リンがキャンプ県の一日県知事に任命されました。\n\n▼キャンプ県の公式サイトはこちら\nhttps://t.co/e8uwkrZnoW\n#キャンプ県…",
          "lang" : "ja"
        }
      },
      {
        "tweet" : {
          "edit_info" : {
            "initial" : {
              "editTweetIds" : [
                "1641899683357548544"
              ],
              "editableUntil" : "2023-03-31T20:56:04.190Z",
              "editsRemaining" : "5",
              "isEditEligible" : false
            }


      ...

*/

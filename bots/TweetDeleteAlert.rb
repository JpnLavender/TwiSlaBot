require 'twitter'
require 'curb'
require 'hashie'
$host = ENV['HOST']

class TweetDeleteChecker

  def initialize(config)
    @config = config
    @rest = Twitter::REST::Client.new(@config)
    @stream = Twitter::Streaming::Client.new(@config)
  end
  attr_reader :config, :rest, :stream

  def run
    streaming_run
  end

  def favo_user 
    @rest.list_members(763286476729704449, count: 1000).map{ |user| user.screen_name }
  end

  def slack_post(attachments)
    conf = { channel: "#bot_tech", username: "Lavender", icon_url: "http://19.xmbs.jp/img_fget.php/_bopic_/923/e05cec.png"}.merge(attachments)
    Curl.post( ENV['WEBHOOKS'],JSON.pretty_generate(conf))
    puts JSON.pretty_generate(conf)
  end

  def slack_post_options(tweet)
    attachments = [{
      author_icon: tweet.user.profile_image_url.to_s,
      author_name: tweet.user.name,
      author_subname: "@#{tweet.user.screen_name}",
      text: tweet.full_text,
      author_link: tweet.uri.to_s,
      color: tweet.user.profile_link_color
    }] 
    if tweet.media
      tweet.media.each_with_index do |v,i|
        attachments[i] ||= {}
        attachments[i].merge!({image_url: v.media_uri })
      end
    end
    slack_post({attachments: attachments})
  end

  def database_post(tweet)
    Curl.post(
      "#{$host}/stocking_tweet",
      ({ 
        tweet_id: tweet.id,
        name: tweet.user.screen_name,
        user_name: tweet.user.name,
        text: tweet.full_text,
        icon: tweet.user.profile_image_url,
        url:tweet.uri, 
        color: tweet.user.profile_link_color
      }).to_json)
  end

  def streaming_run
    @stream.user do |tweet|
      if tweet.is_a?(Twitter::Tweet)
        database_post(tweet)
        case tweet.user.screen_name
        when *favo_user
          unless tweet.full_text =~ /^RT/ 
            slack_post_options(tweet)
            # Tweet.config_rest.favorite(tweet.id)
          end
        end
      elsif tweet.is_a?(Twitter::Streaming::DeletedTweet)
        data = Hashie::Mash.new(JSON.parse(Curl.get("#{$host}/Lavender/find_tweet/#{tweet.id}").body_str))
        if "#{tweet.id}" == data.tweet_id
          data.full_text = "Delete\n" + "#{data.full_text}"
          slack_post_options(data)
        else
          # Slappy.say "誰かがつい消ししたっぽい"
        end
      end
    end
  end

end

CONFIG = {
  consumer_key: ENV["SUB_CONSUMER_KEY"],
  consumer_secret: ENV["SUB_CONSUMER_SECRET"],
  access_token: ENV["SUB_ACCESS_TOKEN"],
  access_token_secret: ENV["SUB_ACCESS_TOKEN_SECRET"]
}

app = TweetDeleteChecker.new(CONFIG)
app.run
module SlackRubyBot
  module Commands
    class Unknown < Base
      match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)

      def self.call(client, data, _match)
        client.say(channel: data.channel, text: "Sorry <@#{data.user}>, I don't understand that command!", gif: 'idiot')
      end
    end
  end
end

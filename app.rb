require 'sinatra'
require 'bundler/setup'
require 'json'
require 'line/bot'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/appdb')

class User < ActiveRecord::Base; end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV['SECRET']
    config.channel_token = ENV['TOKEN']
  }
end

post '/callback' do
  body = request.body.read
  events = client.parse_events_from(body)
  events.each{ |event|
    case event
    when Line::Bot::Event::Follow
      userid = event['source']['userId']
      message = {}
      user = User.new
      user.userId = userid
      user.save
      message = {type: 'text', text: '登録しました'}
      client.push_message(user.userId, message)
    when Line::Bot::Event::Unfollow
      userid = event['source']['userId']
      user = User.find_by(userId: userid)
      user.destroy
    end
  }
end

post '/send' do
  users = User.all
  users.each{ |user|
    message = {type: 'text', text: params[:msg]}
    client.push_message(user.userId, message)
  }
end

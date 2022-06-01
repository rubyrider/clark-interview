autoload :RewardCalculator, './reward_calculator'

require 'sinatra'

get '/' do
  erb :index, locals: { entries: @entries }
end

post '/rewards' do
  file = params[:reward][:tempfile]
  
  reward_builder = ::RewardCalculator.new(file)
  
  if reward_builder.valid?
    reward_builder.call.to_json
  else
    reward_builder.errors.map(&:to_json)
  end
end

json.array!(@games) do |game|
  json.extract! game, :id, :p1o, :p1d, :p2o, :p2d, :p1damage, :p2damage
  json.url game_url(game, format: :json)
end

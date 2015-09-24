class Game < ActiveRecord::Base

	serialize :p1d
	serialize :p1o 
	serialize :p2d
	serialize :p2o
	
end

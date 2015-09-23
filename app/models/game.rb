class Game < ActiveRecord::Base

	serialize :p1d
	serialize :p1o 
	serialize :p2d
	serialize :p2o
	attr_accessor :p1damage, :p2damage
	
end

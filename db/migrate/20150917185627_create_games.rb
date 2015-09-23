class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text :p1o
      t.text :p1d
      t.text :p2o
      t.text :p2d
      t.integer :p1damage
      t.integer :p2damage

      t.timestamps null: false
    end
  end
end

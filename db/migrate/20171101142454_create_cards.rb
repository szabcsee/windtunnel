class CreateCards < ActiveRecord::Migration[5.1]
  def change
  	create_table :cards do |t|
  		t.string	:serial_number
  		t.string 	:booking_code
      t.string :amount
      t.date    :expiry_date
  		t.timestamps null: false
  	end
  end
end

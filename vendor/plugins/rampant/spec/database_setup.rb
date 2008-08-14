module DatabaseSetup
  #ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
 
  # AR keeps printing annoying schema statements
  #$stdout = StringIO.new
 
  def setup_db
    ActiveRecord::Base.logger
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table :thingies do |t|
        t.string :name
      end
    end
  end
   
  def teardown_db
    ActiveRecord::Base.connection.drop_table(:thingies)
  end
end

class AddUuidExtension < ActiveRecord::Migration
  def change
    exec_query 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
  end
end

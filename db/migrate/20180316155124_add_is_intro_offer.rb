class AddIsIntroOffer < ActiveRecord::Migration
  def change
    add_column :packages, :is_intro_offer, :boolean
    Package.reset_column_information
    Package.where("friend_credits > 0").update_all(is_intro_offer: true)
  end
end

class AddPackageExpiry < ActiveRecord::Migration
  def change
    # add_column :packages, :expiry_text, :string
    # Package.reset_column_information
    # exp_info = {
    #   10101 => '30 days',
    #   10103 => '12 months',
    #   10105 => '12 months',
    #   10102 => '6 months',
    #   10161 => '30 days'
    # }
    #
    # exp_info.each do |id, val|
    #   Package.find(id).update_attribute(:expiry_text, val)
    # end
  end
end

class UpdateEmailPrefsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(user_id)
    user = User.find(user_id)
    MindBodyApi.new.update_user(
      id: user.id,
      email: user.email,
      first_name: user.fullname.first,
      middle_name: user.fullname.middle,
      last_name: user.fullname.last,
      birthday: user.birthdate,
      shoe_size: user.shoe_size
    )
    puts "#{user_id} Updated successfully".green
  rescue => e
    puts "There was an error updating #{user_id}: #{e.message}".red
    raise e
  end
end

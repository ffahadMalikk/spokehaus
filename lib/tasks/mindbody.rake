require './lib/file_system_logger'

namespace :mb do

  desc "test"
  task test: :environment do
    File.open('./mb-test.log', 'w') { |f| f.write(Time.now.to_s) }
  end

  desc "get the list of custom fields"
  task custom_fields: :environment do
    ap MindBodyApi.new.get_custom_client_fields
  end

  desc "get the list of locations"
  task locations: :environment do
    ap MindBodyApi.new.get_locations
  end

  desc "sync instructors and classes with the API"
  task sync: :environment do
    logger = FileSystemLogger.new('mindbody_sync.log')
    sync = MindBodySync.new(logger)
    sync.all
  end

  desc "get the activation code"
  task activation_code: :environment do
    ap MindBodyApi.new.get_activation_code
  end

  desc "get the list of services"
  task services: :environment do
    ap MindBodyApi.new.get_services
  end

  desc "get the list of programs"
  task programs: :environment do
    ap MindBodyApi.new.get_programs
  end

  desc "get class"
  task get_class: :environment do
    date = Date.new(2015, 12, 30)
    ap MindBodyApi.new.get_class(
      id: 56,
      client_id: 14,
      start_time: date.beginning_of_day,
      end_time: date.end_of_day,
    )
  end

  desc "get all users"
  task get_all_users: :environment do
    users = MindBodyApi.new.get_all_users
    File.open('users.json', 'w') do |file|
      file.write(users.to_json)
    end
  end

  desc "Update email preferences of all users"
  task update_email_prefs: :environment do
    User.registered.pluck(:id).each do |user_id|
      UpdateEmailPrefsWorker.perform_async(user_id)
    end
  end

  desc "try to add a user to 2 bookings at once"
  task add: :environment do
    api = MindBodyApi.new
    user = User.find_by!(email:'ben@unspace.ca')
    cls = ScheduledClass.last

    ap api.book_client_to_class(user.id, cls, bikes: 2)
  end

  desc "try to add a user to 2 bookings at once"
  task remove: :environment do
    api = MindBodyApi.new
    user = User.find_by!(email:'ben@unspace.ca')
    cls = ScheduledClass.last

    ap api.remove_clients_from_classes(user.id, cls.id)
  end
end

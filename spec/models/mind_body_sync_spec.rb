require './lib/file_system_logger'
require 'rails_helper'

RSpec.describe MindBodySync, type: :model do

  context 'staff' do

    it "creates staff that don't already exist in the db" do
      sync = create_sync
      expect { sync.staff }.to change { Staff.count }.by(11)
    end

    it 'merges info on staff that do already exist' do

      existing = create(:staff, id: 100000003, name: 'Very Wrong')

      sync = create_sync
      expect { sync.staff }.to change { Staff.count }.by(10)
      expect(existing.reload.name).to eq 'CATHERINE MORTIMER'
    end

    it 'removes staff that no longer exist upstream' do

      existing = create(:staff, name: 'Fired McGonzo')

      create_sync.staff
      expect { existing.reload }.to raise_error ActiveRecord::RecordNotFound
    end

  end

  context 'packages' do

    it "creates packages that don't already exist in the db" do
      sync = create_sync
      expect { sync.services }.to change { Package.count }.by(4)
    end

    it 'merges info on packages that do already exist' do
      existing = create(:package, id: 10102, name: 'Amazing Ride')

      sync = create_sync
      expect { sync.services }.to change { Package.count }.by(3)
      expect(existing.reload.name).to eq '5 RIDES'
    end

    it 'removes packages that no longer exist upstream' do

      existing = create(:package, name: 'Free everything always')

      create_sync.services
      expect { existing.reload }.to raise_error ActiveRecord::RecordNotFound
    end

  end

  context 'classes' do

    it "creates scheduled classes that don't already exist in the db" do
      # Given that we've already synced staff
      sync = create_sync
      expect(sync.staff).to be true

      expect { sync.classes }.to change { ScheduledClass.count }.by(5)
    end

    it 'updates existing classes with the incoming info' do
      # Given that we've already synced staff
      sync = create_sync
      expect(sync.staff).to be true

      # and we have an existing class scheduled
      existing = create(:scheduled_class, id: 1831, is_canceled: true)

      # when we sync classes, Then we don't create a new record
      expect { sync.classes }.to change { ScheduledClass.count }.by(4)

      # and the existing record is updated
      expect(existing.reload).to_not be_canceled
    end

    it 'does NOT remove old classes outside of the scheduling window' do
      sync = create_sync

      # create a class that before the current scheduling window
      before_scheduling_window = sync.scheduling_window.start - 1.day
      old_class = create(:scheduled_class, start_time: before_scheduling_window)

      expect(sync.staff).to be true

      expect { sync.classes }.to change { ScheduledClass.count }.by(5)
      expect { old_class.reload }.to_not raise_error
    end

    it 'removes classes that are not mentioned in the scheduling window' do
      sync = create_sync

      # create a class that within the current scheduling window
      within_scheduling_window = sync.scheduling_window.start + 1.day
      old_class = create(:scheduled_class,
        start_time: within_scheduling_window,
        end_time: within_scheduling_window + 45.minutes)

      expect(sync.staff).to be true

       # 5 added, 1 deleted
      expect { sync.classes }.to change { ScheduledClass.count }.by(4)
      expect { old_class.reload }.to raise_error ActiveRecord::RecordNotFound
    end

  end

  def create_sync
    logger = instance_double(FileSystemLogger, 'log')
    MindBodySync.new(logger)
  end

end

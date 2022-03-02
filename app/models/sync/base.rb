class Sync::Base

  def self.merge(*args)
    self.new.merge(*args)
  end

  def initialize(model)
    @model = model
  end

  def merge(records, pruning_scope = nil)
    @model.transaction do
      incoming_ids = records.map(&:id)

      ids_to_delete = @model.pluck(:id) - incoming_ids

      pruning_scope ||= @model
      pruning_scope.where(id: ids_to_delete).destroy_all

      existing_records = @model.where(id: incoming_ids)
      records.map do |record|
        existing = existing_records.detect { |s| s.id == record.id }
        begin
          if existing.present?
            existing.update(slice_incoming_attrs(@model, record))
          else
            @model.create(record.attributes)
          end
        rescue ActiveRecord::RecordInvalid => e
          Honeybadger.notify(e)
        end
      end.all?
    end
  end

  def slice_incoming_attrs(model, record)
    columns = model.column_names.delete_if do |k, _|
      k == 'created_at' || k == 'updated_at'
    end
    record.attributes.slice(*columns)
  end

end

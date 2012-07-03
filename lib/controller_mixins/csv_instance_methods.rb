module ControllerMixins
  module CsvInstanceMethods
    require 'csv'

    def to_csv(objects, skip_attributes=[], delimiter= ",")
      return "" if objects.blank?
      objects_class = objects.first.class
      filtered_columns = objects_class.column_names - skip_attributes
      CSV.generate do |csv|
        csv << filtered_columns
        objects.each do |object|
          csv << filtered_columns.collect { |a| object.attributes[a].blank? ? '' : "'#{object.attributes[a]}'" }
        end
      end
    end
  end
end

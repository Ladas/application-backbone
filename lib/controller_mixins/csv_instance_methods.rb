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

    def generate_and_return_csv(csv_array, name = "export.csv", encoding = "UTF-8", delimiter = ";")
      csv = CSV.generate(encoding: encoding, col_sep: delimiter, force_quotes: true) do |csv|
        csv_array.each do |row|
          csv << row
        end
      end

      #Then spit out the csv with BOM as the response:
      csv = "\xEF\xBB\xBF".force_encoding("UTF-8") + csv if ["UTF-8"].include?(encoding)

      csv = "\xFF\xFE".force_encoding("UTF-16LE") + csv if ["UTF-16LE"].include?(encoding)


      send_data csv, :type => 'text/csv', :filename => name #,:disposition => 'attachment'
    end

    def get_data_for_csv_from_settings(settings, encoding = "UTF-8")
      data_for_csv = []
      header_of_names = []
      header_of_labels = []
      settings[:columns].each do |c|
        header_of_names << c[:name].to_s.encode(encoding, "UTF-8")
        header_of_labels << c[:label].to_s.encode(encoding, "UTF-8")
      end
      data_for_csv << header_of_names
      data_for_csv << header_of_labels

      settings[:data].each do |c|
        row = []
        c.each_pair do |name, value|
          row << value.to_s.encode(encoding, "UTF-8")
        end
        data_for_csv << row
      end
      data_for_csv
    end
  end
end

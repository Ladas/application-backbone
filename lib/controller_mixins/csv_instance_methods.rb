#encoding: utf-8
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


    def make_import_csv(model_class, import_settings = nil)
      if request.post? && params[:file].present?
        
        col_sep = params[:col_sep]
        col_sep = ";" if col_sep.blank?
        
        
        infile = params[:file].read

        # whether it should be updated is decided by user by checkbox
        update_existing = params[:update_existing]
        unique_attribute_for_update = import_settings[:unique_attribute_for_update]

        # additional row data will be added to each row
        additional_row_data = import_settings[:additional_row_data]

        @successful_updates = 0
        @successful_creates = 0
        @errors = []
        @label_header = []
        header = []

        white_list = model_class.get_white_list(import_settings)

        row_number = 0
        CSV.parse(infile, :encoding => "UTF-8", :col_sep => col_sep) do |row|
          row_number += 1

          # SKIP: header
          if row_number == 1
            header = model_class.build_header_from_csv(row, white_list)
            next
          end

          if row_number == 2
            @label_header = model_class.build_header_from_csv(row, white_list)
            next
          end

          row_data = model_class.build_record_from_csv(row, header, white_list)
          # merging with additional data if there are some
          row_data.merge!(additional_row_data) unless additional_row_data.blank?


          import_operation = :create
          if update_existing
            # updating is allowed
            if (row_obj = model_class.where(unique_attribute_for_update => row_data[unique_attribute_for_update]).first)
              import_operation = :update
              row_obj.assign_attributes(row_data)
            else
              row_obj = model_class.new(row_data)
            end
          else
            row_obj = model_class.new(row_data)
          end

          if row_obj.save
            case import_operation
              when :create
                @successful_creates += 1
              when :update
                @successful_updates += 1
            end

          else
            error_message = ""
            row_obj.errors.full_messages.each do |msg|
              error_message += ". " unless error_message.blank?
              error_message += msg
            end

            @errors << {:row_number => row_number, :row => row, :error_message => error_message}
          end
          # build_from_csv method will map customer attributes &
          # build new customer record
          #customer = Customer.build_from_csv(row)
          ## Save upon valid
          ## otherwise collect error records to export
          #if customer.valid?
          #  customer.save
          #else
          #  errs << row
          #end
        end

        render :action => :import_csv
      else
        flash[:error] = "Musíte vybrat soubor pro import "
        redirect_to :action => :import_csv
      end
    end


  end
end

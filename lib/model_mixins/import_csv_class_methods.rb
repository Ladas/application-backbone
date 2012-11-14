module ModelMixins
  module ImportCsvClassMethods
    def build_record_from_csv(row, header, white_list)
      record_hash = {}
      row.each_with_index do |value, index|
        unless value.blank?
          #case header[index]
          #  when "name"
          #    subject = AcquisitionSubject.find_by_name(value)
          #    record_hash[:acquisition_subject_id] = subject.id if !subject.blank? && white_list.include?("acquisition_subject_id")
          #  when "acquisition_subject_status"
          #    status = AcquisitionSubject.status_id(value)
          #    record_hash[header[index]] = status.to_s.force_encoding("UTF-8") if !status.blank? && white_list.include?(header[index])
          #  when "price", "end_price_on_square_m", "payed_in_deposit", "area"
          #    value.gsub!(",", ".") # desetinna tecka
          #    numbers = value.scan /[-+]?\d*\.?\d+/
          #    price = numbers*""
          #    record_hash[header[index]] = price.force_encoding("UTF-8") if !price.blank? && white_list.include?(header[index])
          #  when "code"
          #    currency = Currency.find_by_code(value)
          #    record_hash[:currency_id] = currency.id if !currency.blank? && white_list.include?("currency_id")
          #  when "date_of_signature", "maturity_by_ks", "end_date_by_ks"
          #    datetime = DateTime.parse(value)
          #    record_hash[header[index]] = datetime if !datetime.blank? && white_list.include?(header[index])
          #  else
          record_hash[header[index]] = value.force_encoding("UTF-8") if white_list.include?(header[index])
          #end
        end
      end
      record_hash
    end

    def build_header_from_csv(row, white_list)
      header = row
    end

    def get_white_list(import_settings = nil)
      white_list = []
      except = import_settings.blank? ? nil : import_settings[:except]
      only = import_settings.blank? ? nil : import_settings[:only]

      attr_accessible[:default].each do |v|
        white_list << v if !v.blank?
      end

      unless only.blank?
        white_list &= only # intersect
      end

      unless except.blank?
        white_list -= except # difference
      end
      white_list
    end
  end
end
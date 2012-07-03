module ModelMixins::TableBuilderClassMethods
  def prepare_settings(logged_user, object, settings, params, per_page = 10)
    params[:page] = 1 if params[:page].blank?
    params[:order_by] = settings[:default][:order_by] if params[:order_by].blank?
    params[:order_by_direction] = settings[:default][:order_by_direction] if params[:order_by_direction].blank?
    params[:per_page] = per_page

    not_selected_items = object.filter(settings, params, per_page)
    items = not_selected_items.selection(settings)
    if params[:page].to_i > items.total_pages && items.total_pages > 0
      params[:page] = 1
      not_selected_items = object.filter(settings, params, per_page)
      items = not_selected_items.selection(settings)
    end

    if settings[:template].blank?
      another_global_formats = []
      another_formats = []
      column_methods = []
      settings[:columns].each do |col|
        unless col[:global_format_method].blank?
          # ToDo dodelat moznost predani parametru do formatovaci metody
          another_global_format = {:global_format_method => col[:global_format_method],
                                   :name => col[:name].blank? ? col[:global_format_method] : col[:name],
                                   :table => col[:table]}
          another_global_formats << another_global_format
        end
        unless col[:format_method].blank?
          another_format = {:format_method => col[:format_method],
                            :name => col[:name].blank? ? col[:format_method] : col[:name],
                            :table => col[:table]}
          another_formats << another_format
        end
        unless col[:column_method].blank?
          column_methods << {:column_method => col[:column_method],
                             :name => col[:name],
                             :table => col[:table],
                             :column_class => col[:column_class],
                             :column_params => col[:column_params]
          }
        end
      end


      all_items = items.all # maybe can be done more optimal
                            # same as template_items below, loads objects so column method are better to use
                            # todo think about, but I dont need object, because it's making the same query twice, I just need class and with one outer join it return filtered data, and i include includes to it
                            #template_items = object.joins("RIGHT OUTER JOIN (" + not_selected_items.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
      if object.respond_to?(:klass)
        template_items = object.klass.joins("RIGHT OUTER JOIN (" + not_selected_items.uniq.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
      else
        template_items = object.joins("RIGHT OUTER JOIN (" + not_selected_items.uniq.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
      end

      template_items = template_items.includes(settings[:includes])

      #template_items.all
      # todo dat do knowledge base, kdyz chci aby fungoval include nesmim volat all
      #template_items.each {|t| t.meeting_registrations.each {|x| puts x.inspect}}

      another_columns = {}
      unless column_methods.blank?
        column_method_settings = {:params => params}
        column_methods.each do |column_method|
          column_method_settings[:column_params] = column_method[:column_params]
          #all items == array of array items
          #template items == AREL
          if column_method[:column_class].blank?
            if object.respond_to?(:klass)
              another_columns[column_method[:column_method]] = object.klass.send(column_method[:column_method], logged_user, all_items, template_items, column_method_settings)
            else
              another_columns[column_method[:column_method]] = object.send(column_method[:column_method], logged_user, all_items, template_items, column_method_settings)
            end
          else
            column_method[:column_class] = column_method[:column_class].constantize if column_method[:column_class].kind_of?(String)
            another_columns[column_method[:column_method]] = column_method[:column_class].send(column_method[:column_method], logged_user, all_items, template_items, column_method_settings)
          end
        end
      end

      if another_global_formats.blank? && another_formats.blank? && column_methods.blank?
        items_array = items
      else
        items_array = []
        all_items.each do |i|
          attrs = i.attributes
          another_global_formats.each do |another_global_format|
            # todo udelat moznost predani dalsich parametru
            attrs.merge!({"#{another_global_format[:table]}_#{another_global_format[:name]}" => i.send(another_global_format[:global_format_method].to_sym, attrs["#{another_global_format[:table]}_#{another_global_format[:name]}"])})
          end
          another_formats.each do |another_format|
            attrs.merge!({"#{another_format[:table]}_#{another_format[:name]}" => i.send(another_format[:format_method].to_sym, attrs["#{another_format[:table]}_#{another_format[:name]}"])})
          end
          column_methods.each do |column_method|
            another_column_row = "-"
            another_column_row = another_columns[column_method[:column_method]][attrs['row_id']] if !another_columns.blank? && !another_columns[column_method[:column_method]].blank? && !another_columns[column_method[:column_method]][attrs['row_id']].blank?
            attrs.merge!({"#{column_method[:table]}_#{column_method[:name]}" => another_column_row})
          end

          items_array << attrs
        end
      end

      settings.merge!({:data => items_array})
    else
      template_items = object.joins("RIGHT OUTER JOIN (" + not_selected_items.uniq.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
      settings.merge!({:data => template_items})
    end
    settings.merge!({:data_paginate => items})
    settings.merge!({:params => params})
    settings
  end

  def selection(settings)
    select_string = ""
    settings[:columns].each do |col|
      col[:table] = "unknown" if col[:table].blank?
      if col[:column_method].blank? && col[:row_method].blank? && !col[:name].blank?
        select_string += ", " unless select_string.blank?
        select_string += "#{col[:table]}.#{col[:name]} AS #{col[:table]}_#{col[:name]}"
      end
    end

    select_string += ", " unless select_string.blank?
    select_string += "#{settings[:row][:id]} AS row_id "

    select(select_string)
  end

  def filter(settings, params, per_page = 10)
    order_by = params[:order_by] +' '+ params[:order_by_direction]


    cond_str = ""
    cond_hash = {}
    if !params.blank? && params['find']
      params['find'].each_pair do |i, v|
        unless v.blank?
          cond_str += " AND " unless cond_str.blank?
          cond_id = "find_#{i.gsub(/\./, '_')}"
          cond_str += "#{i} LIKE :#{cond_id}" #OR guest_email LIKE :find"
          cond_hash.merge!({cond_id.to_sym => "%#{v}%"})
        end
      end
    end

    if !params.blank? && params['multichoice']
      params['multichoice'].each_pair do |i, v|
        unless v.blank?
          cond_str += " AND " unless cond_str.blank?
          cond_id = "multichoice_#{i.gsub(/\./, '_')}"

          cond_str += "#{i} IN (:#{cond_id})" #OR guest_email LIKE :find"
          cond_hash.merge!({cond_id.to_sym => v})
        end
      end
    end

    if !params.blank? && params['date_from']
      params['date_from'].each_pair do |i, v|
        unless v.blank?
          cond_str += " AND " unless cond_str.blank?
          cond_id = "date_from_#{i.gsub(/\./, '_')}"
          cond_str += "#{i} >= :#{cond_id}" #OR guest_email LIKE :find"
          cond_hash.merge!({cond_id.to_sym => "#{v}"})
        end
      end
    end

    if !params.blank? && params['date_to']
      params['date_to'].each_pair do |i, v|
        unless v.blank?
          cond_str += " AND " unless cond_str.blank?
          cond_id = "date_to_#{i.gsub(/\./, '_')}"
          cond_str += "#{i} <= :#{cond_id}" #OR guest_email LIKE :find"
          cond_hash.merge!({cond_id.to_sym => "#{v}"})
        end
      end
    end

    #items = self.joins("LEFT OUTER JOIN intranet_text_pages ON resource_id = intranet_text_pages.id").where(cond_str, cond_hash).paginate(:page => params[:page], :per_page => per_page).order(order_by).selection(settings)
    #if params[:page].to_i > items.total_pages && items.total_pages > 0
    #  params[:page] = 1
    #  items = self.where(cond_str, cond_hash).paginate(:page => params[:page], :per_page => per_page).order(order_by).selection(settings)
    #end
    #items
    where(cond_str, cond_hash).paginate(:page => params[:page], :per_page => per_page).order(order_by)
  end
end

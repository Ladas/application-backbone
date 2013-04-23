module ModelMixins
  module TableBuilderClassMethods
    @@can_edit_description = false
    class << self
      attr_accessor :can_edit_description
    end


    def prepare_settings(logged_user, object, settings, params, per_page = 10, forced_per_page = nil)
      params[:page] = 1 if params[:page].blank?
      params[:order_by] = settings[:default][:order_by] + " " + settings[:default][:order_by_direction] if params[:order_by].blank? && !settings[:default][:order_by].blank? && !settings[:default][:order_by_direction].blank?

      params[:order_by] = settings[:default][:order] if params[:order_by].blank? && !settings[:default][:order].blank?

      # there are allowed per_pages in the settings[:per_page]
      unless settings[:per_page].blank?
        unless params["per_page_chosen"].blank?
          params[:per_page] = settings[:per_page].include?(params["per_page_chosen"].to_i) ? params["per_page_chosen"].to_i : settings[:per_page].first
        end
      end

      if params[:per_page].blank?
        #default per page from Class variable set in initializer
        params[:per_page] = ModelMixins::TableBuilderClassMethods::PER_PAGE if defined?(ModelMixins::TableBuilderClassMethods::PER_PAGE)

        #or with higher priority from table definition
        params[:per_page] = settings[:default][:per_page] if params[:per_page].blank? && !settings[:default][:per_page].blank?
      end
      params[:per_page] = per_page if params[:per_page].blank?
      # forcing per page for print, export of all, etc., there will be maximum, later I can add ___unlimited___
      params[:per_page] = forced_per_page unless forced_per_page.blank?
      per_page = params[:per_page]


      # method below can change this if there were some virtual non exixtent columns
      params[:real_order_by] = params[:order_by]
      check_non_existing_colum_order_by(settings, params)

      not_selected_items = object.filter(object, settings, params, per_page)
      items = not_selected_items.selection(settings)
      if items.respond_to?(:total_pages) && params[:page].to_i > items.total_pages && items.total_pages > 0
        params[:page] = 1
        not_selected_items = object.filter(object, settings, params, per_page)
        items = not_selected_items.selection(settings)
      end

      # todo when template passed, this code is not probably needed
      # the array of items, Will be filled with column method values, formatting values, etc.
      all_items = items.all # maybe can be done more optimal
      all_items_row_ids = all_items.collect { |x| x.row_id }.uniq

      # summarization will be in one query, otherwise it takes a lot of time to do it in many
      summarized_paged_cols = []
      summarized_all_cols = []

      if settings[:template].blank?
        # initialize another_global_formats,another_formats and column_methods
        another_global_formats = []
        another_formats = []
        column_methods = []
        settings[:columns].each do |col|
          if !col[:summarize_page].blank? && col[:summarize_page]
            # mysql SUM of the collumn on the page
            # passing all_items.total_entries because I don't want it to count again
            if all_items.kind_of?(WillPaginate::Collection)
              # if this is not will paginate collection, it means there is no pagination, so there wont be summary of page
              #col[:summarize_page_value] = sumarize(object, col, object.filter(object, settings, params, per_page, all_items.total_entries).selection(settings))
              summarized_paged_cols << col
            end
          end

          if !col[:summarize_all].blank? && col[:summarize_all]
            # mysql SUM of the collumn off all data
            #col[:summarize_all_value] = sumarize(object, col, object.filter(object, settings, params, false).selection(settings))
            summarized_all_cols << col
          end


          unless col[:global_format_method].blank?
            # ToDo dodelat moznost predani parametru do formatovaci metody
            col[:name] = col[:name].blank? ? "non_existing_column___" + col[:global_format_method] : col[:name]
            another_global_format = {:global_format_method => col[:global_format_method],
                                     :name => col[:name],
                                     :table => col[:table]}
            another_global_formats << another_global_format
          end
          unless col[:format_method].blank?
            col[:name] = col[:name].blank? ? "non_existing_column___" + col[:format_method] : col[:name]
            another_format = {:format_method => col[:format_method],
                              :name => col[:name],
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

        # making all summarizations in 2 queries
        summarized_paged_cols_arel = nil
        summarized_all_cols_arel = nil

        summarized_paged_cols_arel = object.filter(object, settings, params, per_page, all_items.total_entries).selection(settings) unless summarized_paged_cols.blank?
        summarized_all_cols_arel = object.filter(object, settings, params, false).selection(settings) unless summarized_all_cols.blank?
        make_sumarizations!(object, summarized_paged_cols, summarized_paged_cols_arel, summarized_all_cols, summarized_all_cols_arel)


        # same as template_items below, loads objects so column method are better to use
        # todo think about, but I dont need object, because it's making the same query twice, I just need class and with one outer join it return filtered data, and i include includes to it
        #template_items = object.joins("RIGHT OUTER JOIN (" + not_selected_items.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
        # the AREL with items
        if object.respond_to?(:klass)
          #template_items = object.klass.joins("RIGHT OUTER JOIN (" + items.uniq.to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
          # more optimalized
          template_items = object.klass.where("#{settings[:row][:id]}" => all_items_row_ids)
        else
          #template_items = object.joins("RIGHT OUTER JOIN (" + items.uniq.to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
          template_items = object.where("#{settings[:row][:id]}" => all_items_row_ids)
        end

        # loading colors for editable table
        editable_table_load_colors(settings, object, all_items_row_ids)

        template_items = template_items.includes(settings[:includes])

        #template_items.all
        # todo dat do knowledge base, kdyz chci aby fungoval include nesmim volat all
        #template_items.each {|t| t.meeting_registrations.each {|x| puts x.inspect}}

        # calling column methods
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

        # updating items by another_global_formats,another_formats, column_methods, summary_methods
        if another_global_formats.blank? && another_formats.blank? && column_methods.blank? &&
            items_array = items
        else
          items_array = []
          all_items.each do |i|
            attrs = i.attributes
            another_global_formats.each do |another_global_format|
              # todo udelat moznost predani dalsich parametru
              case another_global_format[:table]
                when "___sql_expression___"
                  col_name = "#{another_global_format[:name]}"
                else
                  col_name = "#{another_global_format[:table]}_#{another_global_format[:name]}"
              end
              attrs.merge!({col_name => i.send(another_global_format[:global_format_method].to_sym, attrs[col_name])})
            end
            another_formats.each do |another_format|
              case another_format[:table]
                when "___sql_expression___"
                  col_name = "#{another_format[:name]}"
                else
                  col_name = "#{another_format[:table]}_#{another_format[:name]}"
              end

              attrs.merge!({col_name => i.send(another_format[:format_method].to_sym, attrs[col_name])})
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
        #template_items = object.joins("RIGHT OUTER JOIN (" + not_selected_items.uniq.select(settings[:row][:id] + " AS row_id").to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
        if object.respond_to?(:klass)
          template_items = object.klass.joins("RIGHT OUTER JOIN (" + items.uniq.to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
        else
          template_items = object.joins("RIGHT OUTER JOIN (" + items.uniq.to_sql + ") temp_template_query ON #{settings[:row][:id]} = temp_template_query.row_id")
        end

        template_items = template_items.includes(settings[:includes])
        settings.merge!({:data => template_items})
      end

      # summary_methods 
      unless settings[:summaries].blank?
        summaries = settings[:summaries]
        summaries.each do |summary|
          summary_settings = {:params => params}
          summary_settings[:summary_params] = summary[:summary_params]

          if summary[:summary_class].blank?
            if object.respond_to?(:klass)
              val = object.klass.send(summary[:summary_method], logged_user, all_items, template_items, object, summary_settings)
            else
              val = object.send(summary[:summary_method], logged_user, all_items, template_items, object, summary_settings)
            end
          else
            summary_class = summary[:summary_class].constantize if summary[:summary_class].kind_of?(String)
            val = summary_class.send(summary[:summary_method], logged_user, all_items, template_items, object, summary_settings)
          end
          if val.kind_of?(Hash)
            summary[:value] = val[:value]
            summary[:class] = val[:class]
          else
            summary[:value] = val
          end
        end

      end


      settings.merge!({:data_paginate => items})
      settings.merge!({:params => params})
      settings
    end

    def make_sumarizations!(object, summarized_paged_cols, paged_cols_arel, summarized_all_cols, all_cols_arel)
      # make summarizations, will set it in the given cols
      unless summarized_paged_cols.blank?
        sumarize_collection!(object, summarized_paged_cols, paged_cols_arel, :page)
      end
      unless summarized_all_cols.blank?
        sumarize_collection!(object, summarized_all_cols, all_cols_arel, :all)
      end
    end

    def sumarize_collection!(object, cols, items_arel, type)
      # make the col_name aliases and the query
      col_names = {}
      sum_query = ""
      cols.each do |col|
        if col[:sql_expression].blank?
          col_name = "#{col[:table]}_#{col[:name]}"
        else
          col_name = col[:name]
        end

        col_name_alias = col_name + "_sum"

        sum_query += ", " unless sum_query.blank?
        sum_query += "SUM(#{col_name}) AS #{col_name_alias}"
      end

      #make the query
      if object.respond_to?(:klass)
        mysql_sums = object.klass.find_by_sql("SELECT #{sum_query} FROM (" + items_arel.to_sql + ") counts")
      else
        mysql_sums = object.find_by_sql("SELECT #{sum_query} FROM (" + items_arel.to_sql + ") counts")
      end
      sums = mysql_sums.first

      # set the summarization results back to cols
      cols.each do |col|
        if col[:sql_expression].blank?
          col_name = "#{col[:table]}_#{col[:name]}"
        else
          col_name = col[:name]
        end

        col_name_alias = col_name + "_sum"

        # getting summarization value
        sum_value = sums[col_name_alias]

        # formating sum_value, if there is formating method
        format_method = nil
        format_method = col[:format_method] unless col[:format_method].blank?
        format_method = col[:global_format_method] unless col[:global_format_method].blank?

        unless format_method.blank?
          if object.respond_to?(:klass)
            sum_value = object.klass.new.send(format_method.to_sym, sum_value)
          else
            sum_value = object.new.send(format_method.to_sym, sum_value)
          end
        end


        # assigning back to col by type
        case type
          when :all
            col[:summarize_all_value] = sum_value
          when :page
            col[:summarize_page_value] = sum_value
        end
      end
    end

    def sumarize(object, col, items)
      #method for sumarizing values in column

      if col[:sql_expression].blank?
        col_name = "#{col[:table]}_#{col[:name]}"
      else
        col_name = col[:name]
      end

      if object.respond_to?(:klass)
        mysql_count = object.klass.find_by_sql("SELECT SUM(#{col_name}) AS sum_column FROM (" + items.to_sql + ") count")
      else
        mysql_count = object.find_by_sql("SELECT SUM(#{col_name}) AS sum_column FROM (" + items.to_sql + ") count")
      end

      #count = items.sum(col[:name])
      count = mysql_count.first[:sum_column]

      format_method = nil

      format_method = col[:format_method] unless col[:format_method].blank?
      format_method = col[:global_format_method] unless col[:global_format_method].blank?

      unless format_method.blank?
        if object.respond_to?(:klass)
          count = object.klass.new.send(format_method.to_sym, count)
        else
          count = object.new.send(format_method.to_sym, count)
        end
      end

      count
    end

    def selection(settings)
      select_string = ""
      settings[:columns].each do |col|
        col[:table] = "___unknown___" if col[:table].blank?
        col[:table] = "___sql_expression___" unless col[:sql_expression].blank?

        if col[:column_method].blank? && col[:row_method].blank? && !col[:name].blank?
          if col[:sql_expression].blank?
            # I am selection col[:name]
            select_string += ", " unless select_string.blank?
            select_string += "#{col[:table]}.#{col[:name]} AS #{col[:table]}_#{col[:name]}"
          else
            # Iam selecting col[:expression] and col[:name] is alias
            # the expression can be sql expression
            select_string += ", " unless select_string.blank?
            select_string += "#{col[:sql_expression]} AS #{col[:name]}"
          end
        end

        # for select more data in combination with filter_method (etc full_name of user))
        if !col[:table].blank? && !col[:select].blank? && !col[:select_as].blank?
          col[:select_as] = col[:table] if col[:select_as].blank?

          col[:select].split(",").each do |one_select|
            one_select.gsub!(" ", "")
            select_string += ", " unless select_string.blank?
            select_string += "#{col[:select_as]}.#{one_select} AS #{col[:select_as]}_#{one_select}"
          end
        end

        # for (agregated data)
        #if (!col[:select_agregated].blank?
      end

      select_string += ", " unless select_string.blank?
      select_string += "#{settings[:row][:id]} AS row_id "


      select(select_string)
    end

    def process_number_exact_filter(params)
      # this will divide :number_exact filter into find_exact and number_from - number_to filter
      # the condition is look for interval if there is an interval(2 values given) otherwise look for the exact match

      if !params.blank?
        number_exact_from = params['number_exact_from'].blank? ? nil : params['number_exact_from'].dup
        number_exact_to = params['number_exact_to'].blank? ? nil : params['number_exact_to'].dup

        if (!number_exact_from.blank? && !number_exact_to.blank?)
          # if they have whole interval, it will go to number_filter
          number_keys = number_exact_from.keys.delete_if { |x| number_exact_from[x].blank? } &
              number_exact_to.keys.delete_if { |x| number_exact_to[x].blank? }
          number_keys.each do |number_key|
            # move it to number filter
            params['number_from'] ||= {}
            params['number_from'][number_key] = number_exact_from[number_key]
            params['number_to'] ||= {}
            params['number_to'][number_key] = number_exact_to[number_key]

            # and delete it
            number_exact_from.delete(number_key)
            number_exact_to.delete(number_key)
          end
        end

        # the ones with whole interval were removed, I will put the rest in find exact
        if (!number_exact_from.blank?)
          params['find_exact'] ||= {}
          number_exact_from.each_pair do |index, value|
            params['find_exact'][index] = value unless value.blank?
          end
        end

        if (!number_exact_to.blank?)
          params['find_exact'] ||= {}
          number_exact_to.each_pair do |index, value|
            params['find_exact'][index] = value unless value.blank?
          end
        end
      end
      params
    end

    def filter(object, settings, params, per_page = 10, total_count = nil)
      inactive_columns = get_columns_with_inactive_filter


      order_by = params[:real_order_by]

      cond_str = ""
      cond_hash = {}
      having_cond_str = ""
      having_cond_hash = {}

      case settings[:filter_method]
        when "only_by_checkboxes"
          # filtering only by checkboxes
          cond_str = "(#{settings[:row][:id]} IN (:checkboxes))"
          cond_hash = {:checkboxes => params["checkbox_pool"].split(",")}
          per_page = nil # no paginate for checkbox filter
        else
          params = process_number_exact_filter(params)


          # filtering by table filters
          if !params.blank? && params['find']
            params['find'].each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?non_existing_column___.*$/i)
                  identifier = i.split("non_existing_column___").second
                  settings[:columns].each do |col|
                    if !col[:select_as].blank? && !col[:format_method].blank? && col[:format_method] == identifier
                      cond_str += " AND " unless cond_str.blank?
                      cond_str += "( "
                      sub_cond = ""
                      col[:select].split(",").each do |sub_cond_col|
                        sub_cond += " OR " unless sub_cond.blank?
                        non_existing_column_i = col[:select_as] + "." + sub_cond_col.gsub(" ", "")
                        cond_id = "find_#{non_existing_column_i.gsub(/\./, '_')}"
                        sub_cond += "#{non_existing_column_i} LIKE :#{cond_id}" #OR guest_email LIKE :find"
                        cond_hash.merge!({cond_id.to_sym => "%#{v}%"})
                      end
                      cond_str += sub_cond + " )"
                    else
                      ""
                    end
                  end
                else
                  if i.match(/^.*?___sql_expression___.*$/i)
                    i = i.gsub(/___sql_expression___\./, "") #some cleaning job

                    having_cond_str += " AND " unless having_cond_str.blank?
                    cond_id = "find_#{i.gsub(/\./, '_')}"
                    having_cond_str += "#{i} LIKE :#{cond_id}" #OR guest_email LIKE :find"
                    having_cond_hash.merge!({cond_id.to_sym => "%#{v}%"})
                  else
                    cond_str += " AND " unless cond_str.blank?
                    cond_id = "find_#{i.gsub(/\./, '_')}"
                    cond_str += "#{i} LIKE :#{cond_id}" #OR guest_email LIKE :find"
                    cond_hash.merge!({cond_id.to_sym => "%#{v}%"})
                  end
                end
              end
            end
          end

          if !params.blank? && params['find_exact']
            params['find_exact'].each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?non_existing_column___.*$/i)
                  puts "It has to be existing column for exact match"
                else
                  if i.match(/^.*?___sql_expression___.*$/i)
                    i = i.gsub(/___sql_expression___\./, "") #some cleaning job

                    having_cond_str += " AND " unless having_cond_str.blank?
                    cond_id = "find_#{i.gsub(/\./, '_')}"
                    having_cond_str += "#{i} = :#{cond_id}" #OR guest_email LIKE :find"
                    having_cond_hash.merge!({cond_id.to_sym => "#{v}"})
                  else
                    cond_str += " AND " unless cond_str.blank?
                    cond_id = "find_#{i.gsub(/\./, '_')}"
                    cond_str += "#{i} = :#{cond_id}" #OR guest_email LIKE :find"
                    cond_hash.merge!({cond_id.to_sym => "#{v}"})
                  end
                end
              end
            end
          end

          # ToDo ladas add having condition to others
          if !params.blank? && params['multichoice']
            params['multichoice'].each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?___sql_expression___.*$/i)
                  i = i.gsub(/___sql_expression___\./, "") #some cleaning job
                  having_cond_str += " AND " unless having_cond_str.blank?
                  cond_id = "multichoice_#{i.gsub(/\./, '_')}"

                  having_cond_str += "#{i} IN (:#{cond_id})" #OR guest_email LIKE :find"
                  having_cond_hash.merge!({cond_id.to_sym => v})
                else
                  cond_str += " AND " unless cond_str.blank?
                  cond_id = "multichoice_#{i.gsub(/\./, '_')}"

                  cond_str += "#{i} IN (:#{cond_id})" #OR guest_email LIKE :find"
                  cond_hash.merge!({cond_id.to_sym => v})
                end
              end
            end
          end

          if !params.blank? && (params['date_from'])
            from_hash = params['date_from']

            from_hash.each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?___sql_expression___.*$/i)
                  i = i.gsub(/___sql_expression___\./, "") #some cleaning job
                  having_cond_str += " AND " unless having_cond_str.blank?
                  cond_id = "date_from_#{i.gsub(/\./, '_')}"
                  having_cond_str += "#{i} >= :#{cond_id}" #OR guest_email LIKE :find"
                  having_cond_hash.merge!({cond_id.to_sym => "#{v}"})
                else
                  cond_str += " AND " unless cond_str.blank?
                  cond_id = "date_from_#{i.gsub(/\./, '_')}"
                  cond_str += "#{i} >= :#{cond_id}" #OR guest_email LIKE :find"
                  v = Time.parse(v) # queries to database has to be in utc date
                  cond_hash.merge!({cond_id.to_sym => "#{v.utc}"})
                end
              end
            end
          end

          if !params.blank? && (params['date_to'])
            to_hash = params['date_to']

            to_hash.each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?___sql_expression___.*$/i)
                  i = i.gsub(/___sql_expression___\./, "") #some cleaning job
                  having_cond_str += " AND " unless having_cond_str.blank?
                  cond_id = "date_to_#{i.gsub(/\./, '_')}"
                  having_cond_str += "#{i} <= :#{cond_id}" #OR guest_email LIKE :find"
                  having_cond_hash.merge!({cond_id.to_sym => "#{v}"})
                else
                  cond_str += " AND " unless cond_str.blank?
                  cond_id = "date_to_#{i.gsub(/\./, '_')}"
                  cond_str += "#{i} <= :#{cond_id}" #OR guest_email LIKE :find"
                  v = Time.parse(v) # queries to database has to be in utc date
                  cond_hash.merge!({cond_id.to_sym => "#{v.utc}"})
                end
              end
            end
          end


          if !params.blank? && (params['number_from'])
            from_hash = params['number_from']

            from_hash.each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?___sql_expression___.*$/i)
                  i = i.gsub(/___sql_expression___\./, "") #some cleaning job
                  having_cond_str += " AND " unless having_cond_str.blank?
                  cond_id = "date_from_#{i.gsub(/\./, '_')}"
                  having_cond_str += "#{i} >= :#{cond_id}" #OR guest_email LIKE :find"
                  having_cond_hash.merge!({cond_id.to_sym => "#{v}"})
                else
                  cond_str += " AND " unless cond_str.blank?
                  cond_id = "date_from_#{i.gsub(/\./, '_')}"
                  cond_str += "#{i} >= :#{cond_id}" #OR guest_email LIKE :find"
                  cond_hash.merge!({cond_id.to_sym => "#{v}"})
                end
              end
            end
          end

          if !params.blank? && (params['number_to'])
            to_hash = params['number_to']

            to_hash.each_pair do |i, v|
              next if inactive_columns.include?(i)

              i = i.gsub(/___unknown___\./, "") #some cleaning job
              unless v.blank?
                if i.match(/^.*?___sql_expression___.*$/i)
                  i = i.gsub(/___sql_expression___\./, "") #some cleaning job
                  having_cond_str += " AND " unless having_cond_str.blank?
                  cond_id = "date_to_#{i.gsub(/\./, '_')}"
                  having_cond_str += "#{i} <= :#{cond_id}" #OR guest_email LIKE :find"
                  having_cond_hash.merge!({cond_id.to_sym => "#{v}"})
                else
                  cond_str += " AND " unless cond_str.blank?
                  cond_id = "date_to_#{i.gsub(/\./, '_')}"
                  cond_str += "#{i} <= :#{cond_id}" #OR guest_email LIKE :find"
                  cond_hash.merge!({cond_id.to_sym => "#{v}"})
                end
              end
            end
          end


        #items = self.joins("LEFT OUTER JOIN intranet_text_pages ON resource_id = intranet_text_pages.id").where(cond_str, cond_hash).paginate(:page => params[:page], :per_page => per_page).order(order_by).selection(settings)
        #if params[:page].to_i > items.total_pages && items.total_pages > 0
        #  params[:page] = 1
        #  items = self.where(cond_str, cond_hash).paginate(:page => params[:page], :per_page => per_page).order(order_by).selection(settings)
        #end
        #items
      end
      ret = where(cond_str, cond_hash).order(order_by)
      ret = ret.having(having_cond_str, having_cond_hash) unless having_cond_str.blank?

      # if there are additional joins i will add them
      settings[:columns].each do |col|
        col[:table_primary_key] = "id" if col[:table_primary_key].blank?
        if !col[:join_on].blank?
          join_on_select = col[:select] + ", #{col[:table_primary_key]}" # adding primary key so it can be used in on condition
          ret= ret.joins("LEFT OUTER JOIN (SELECT #{join_on_select} FROM #{col[:table]}) #{col[:select_as]} ON #{col[:select_as]}.#{col[:table_primary_key]}=#{col[:join_on]}")
        end
      end


      if per_page && per_page > 0
        # only when i need pagination
        if total_count.blank?
          # if I call this more times, I can pass the total count and not count it multiple times
          # fuck will paginate, if there are agregated queries that I use for condition, will_paginage will delete it
          # i am counting rows on my own (as sugested in will paginete gem, when the query got more complex)
          if (settings[:total_count_cache].blank?)
            # I am not caching total count. Be advised in table cca. 200 000 rows total count take about 1 second to compute, it very much.
            if object.respond_to?(:klass)
              mysql_count = object.klass.find_by_sql("SELECT COUNT(*) AS count_all FROM (" + ret.selection(settings).to_sql + ") count")
            else
              mysql_count = object.find_by_sql("SELECT COUNT(*) AS count_all FROM (" + ret.selection(settings).to_sql + ") count")
            end

            ret = ret.paginate(:page => params[:page], :per_page => per_page, :total_entries => mysql_count.first[:count_all])
          else
            # I am caching total count
            # todo find out how to cache this when everything can change, maybe I can cache only not filtered version
            # !!!!!!1 dont turn this on till then

            total_count = Rails.cache.fetch(settings[:form_id] + "__cached_total_count", :expires_in => settings[:total_count_cache]) do
              if object.respond_to?(:klass)
                mysql_count = object.klass.find_by_sql("SELECT COUNT(*) AS count_all FROM (" + ret.selection(settings).to_sql + ") count")
              else
                mysql_count = object.find_by_sql("SELECT COUNT(*) AS count_all FROM (" + ret.selection(settings).to_sql + ") count")
              end
              mysql_count.first[:count_all]
            end
            ret = ret.paginate(:page => params[:page], :per_page => per_page, :total_entries => total_count)
          end
        else
          ret = ret.paginate(:page => params[:page], :per_page => per_page, :total_entries => total_count)
        end
      end

      ret
    end

    def get_columns_with_inactive_filter
      inactive_cols = []
      settings[:columns].each do |c|
        if c[:inactive_filter]
          inactive_cols << "#{col[:table]}.#{col[:name]}"
        end
      end
      inactive_cols
    end

    def check_non_existing_colum_order_by(settings, params)
      order_by_params = params[:order_by].dup.gsub(/___unknown___\./, "") #some cleaning job
      order_by_params = order_by_params.gsub(/___sql_expression___\./, "") #some cleaning job

      order_by_arr = order_by_params.split(",")
      order_by_arr.each_with_index do |one_order_by, index|
        if one_order_by.match(/^.*?non_existing_column___.*$/i)
          identifier_and_direction = one_order_by.split("non_existing_column___").second
          identifier = identifier_and_direction.split(" ").first
          order_by_direction = identifier_and_direction.split(" ").second
          settings[:columns].each do |col|
            if !col[:select_as].blank? && !col[:format_method].blank? && col[:format_method] == identifier
              order_by_arr[index] = col[:order_by].gsub(",", " #{order_by_direction} ,") + " #{order_by_direction}"
            else
              ""
            end
          end
        else
          ""
        end
      end
      params[:real_order_by] = order_by_arr*","
    end


    def editable_table_load_colors(settings, object, all_items_row_ids)
      if object.respond_to?(:klass)
        object_class = object.klass
      else
        object_class = object
      end

      # if model has cell colors

      if (object_class.new.respond_to?(:editable_table_cell_colors))
        cell_colors = EditableTableCellColor.where(:owner_type => object_class.to_s, :owner_id => all_items_row_ids).all
        cell_colors_for_settings = {}
        cell_colors.each do |c|
          cell_colors_for_settings[c.owner_id] ||= {}
          cell_colors_for_settings[c.owner_id][c.cell_name] ||= {}
          cell_colors_for_settings[c.owner_id][c.cell_name]["color"] = c.color
          cell_colors_for_settings[c.owner_id][c.cell_name]["background_color"] = c.background_color
        end
        unless cell_colors_for_settings.blank?
          settings.merge!({:cell_colors => cell_colors_for_settings})
        end
      end

      # if model has row colors
      if (object_class.new.respond_to?(:editable_table_row_colors))
        row_colors = EditableTableRowColor.where(:owner_type => object_class.to_s, :owner_id => all_items_row_ids)
        row_colors_for_settings = {}
        row_colors.each do |c|
          row_colors_for_settings[c.owner_id] ||= {}
          row_colors_for_settings[c.owner_id]["color"] = c.color
          row_colors_for_settings[c.owner_id]["background_color"] = c.background_color
        end
        unless row_colors_for_settings.blank?
          settings.merge!({:row_colors => row_colors_for_settings})
        end
      end
    end


  end
end



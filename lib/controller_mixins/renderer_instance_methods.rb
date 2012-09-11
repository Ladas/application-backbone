module ControllerMixins
  module RendererInstanceMethods
    def render_table_for(logged_user, template = nil, &proc)
      @settings[:template] = template unless template.blank?
      data = yield
      class_obj = data.respond_to?(:klass) ? data.klass : data
      if action_name == "filter"
        case params["___display_method___"]
          when "print_by_checkboxes"
            # printing page, it should be opened in new window
            @settings = class_obj.prepare_settings(logged_user, data, @settings, default_params)


            render :layout => "print", :action => :index
          else
            # default print of table
            default_params = params
            if !params.blank? && params["clear"]
              default_params = @settings[:default].dup
              default_params[:order_by] = @settings[:default][:order_by] + " " + @settings[:default][:order_by_direction] if !@settings[:default][:order_by].blank? && !@settings[:default][:order_by_direction].blank?
              default_params[:order_by] = @settings[:default][:order] if !@settings[:default][:order].blank?
            end

            @settings = class_obj.prepare_settings(logged_user, data, @settings, default_params)
            if !params.blank? && params["clear"]
              session["#{@settings[:form_id]}_params"] = ""
              render :layout => false, :action => :index
            else
              @paginate = render_to_string(:partial => "/helpers/build_table_pager", :locals => {:settings => @settings})
              session["#{@settings[:form_id]}_params"] = params
              if @settings[:template].blank?
                # if there is no template a will return json and tbody renders in javascript template
                returned_t_body = @settings.to_json
              else
                # or there is template so i will return template rendered here in ruby
                returned_t_body = render_to_string(:partial => @settings[:template], :locals => {:settings => @settings})
              end

              render :layout => false, :json => {:settings => returned_t_body, :paginate => @paginate}.to_json
            end
        end

      elsif action_name == "index"
        default_params = @settings[:default].dup
        default_params[:order_by] = @settings[:default][:order_by] + " " + @settings[:default][:order_by_direction] if !@settings[:default][:order_by].blank? && !@settings[:default][:order_by_direction].blank?
        default_params[:order_by] = @settings[:default][:order] if !@settings[:default][:order].blank?

        default_params = session["#{@settings[:form_id]}_params"] unless session["#{@settings[:form_id]}_params"].blank?
        @settings = class_obj.prepare_settings(logged_user, data, @settings, default_params)
      end
    end

    ##
    # Nastavi data pro tabulku.
    #
    # @param [Hash] settings
    # @param [User] logger_user
    # @param [String] template
    #
    # @return [Hash | renderuje] Hash vraci pro vykresleni tabulky, renderuje pri filtrovani
    def render_table(settings, logged_user=nil, template = nil, &proc)
      settings[:template] = template unless template.blank?
      data = yield
      class_obj = data.respond_to?(:klass) ? data.klass : data

      filter_method = settings[:filter_method]
      show_table_method = settings[:show_table_method]

      default_params = set_default_params(filter_method, show_table_method, settings)

      case display_method
        when "print_by_checkboxes"
          # vyjímka pro tisk tabulek
          # printing page, it should be opened in new window
          settings[:filter_method] = "only_by_checkboxes"
          settings[:display_method] = display_method
          settings = class_obj.prepare_settings(logged_user, data, settings, default_params)

          render_table_for_printing(settings, show_table_method)
        else
          settings = class_obj.prepare_settings(logged_user, data, settings, default_params)

          # Filtrovani se renderuje zde
          if is_filtering?(filter_method)

            if clear_filter? # Tlacitko Smazat filtr
              render_table_on_clear_filter(settings, show_table_method)
            else # Ostatni filtry
              render_tbody_on_filter(settings)
            end

          end
      end

      # Cele vykresleni stranky normalne z metody, ktera toto zavolala
    end

    def set_default_params(filter_method, show_table_method, settings)
      default_params = params
      default_params = default_params_for_clear_filter(settings) if is_filtering?(filter_method) && clear_filter?
      default_params = default_params_for_show_table(settings) if is_showing_table?(show_table_method)
      default_params
    end

    def render_table_for_printing(settings, show_table_method)
      render :layout => "print", :action => (show_table_method.blank? ? :index : show_table_method)
    end

    def render_table_on_clear_filter(settings, show_table_method)
      session["#{settings[:form_id]}_params"] = ""
      render :layout => false, :action => (show_table_method.blank? ? :index : show_table_method)
    end

    def render_tbody_on_filter(settings)
      paginate = render_to_string(:partial => "/helpers/build_table_pager", :locals => {:settings => settings})
      session["#{settings[:form_id]}_params"] = params
      if settings[:template].blank?
        # if there is no template a will return json and tbody renders in javascript template
        returned_t_body = settings.to_json
      else
        # or there is template so i will return template rendered here in ruby
        returned_t_body = render_to_string(:partial => settings[:template], :locals => {:settings => settings})
      end

      render :layout => false, :json => {:settings => returned_t_body, :paginate => paginate}.to_json
    end

    def clear_filter?
      !params.blank? && params["clear"]
    end

    def display_method
      params["___display_method___"]
    end

    def default_params_for_clear_filter(settings)
      default_params = settings[:default].dup
      default_params[:order_by] = settings[:default][:order_by] + " " + settings[:default][:order_by_direction] if !settings[:default][:order_by].blank? && !settings[:default][:order_by_direction].blank?
      default_params[:order_by] = settings[:default][:order] if !settings[:default][:order].blank?
      default_params
    end

    def default_params_for_show_table(settings)
      default_params = settings[:default].dup
      default_params[:order_by] = settings[:default][:order_by] + " " + settings[:default][:order_by_direction] if !settings[:default][:order_by].blank? && !settings[:default][:order_by_direction].blank?
      default_params[:order_by] = settings[:default][:order] if !settings[:default][:order].blank?

      default_params = session["#{settings[:form_id]}_params"] unless session["#{settings[:form_id]}_params"].blank?
      default_params
    end


    def is_showing_table?(show_table_method)
      action_name == "index" ||
          (!show_table_method.blank? && action_name == show_table_method)
    end

    def is_filtering?(filter_method)
      action_name == "filter" ||
          (!filter_method.blank? && action_name == filter_method)
    end


    def fill_settings_with opts
      settings = {}
      settings[:symlink_remote] = true
      unless opts.at(0).nil?
        opts = opts[0]
        settings[:symlink_controller] = opts.include?(:controller) ? opts[:controller] : controller_name
        settings[:symlink_outer_controller] = opts[:outer_controller] if opts.include?(:outer_controller)
        settings[:symlink_outer_id] = opts[:outer_id] if opts.include?(:outer_id)
        settings[:symlink_action] = opts[:action] if opts.include?(:action)
        settings[:symlink_id] = opts[:id] if opts.include?(:id)
      else
        settings[:symlink_controller] = controller_name
      end
      settings
    end

    def build_url_path_method(opts)
      path = ""

      opts = opts[0] unless opts.at(0).nil?

      path += '/' + opts[:outer_controller].to_s if opts.include?(:outer_controller)
      path += '/' + opts[:outer_id].to_s if opts.include?(:outer_id)
      path += opts.include?(:controller) ? '/' + opts[:controller].to_s : '/' + controller_name
      path += '/' + opts[:id].to_s if opts.include?(:id)
      path += '/' + opts[:action].to_s if opts.include?(:action)

      path
    end

    # redirect do indexu pokud neni zaznam v db
    def redirect_not_found(*opts)
      if request.xhr?
        render :json => {:message => I18n.t("activerecord.errors.messages.record_not_found"), :settings => fill_settings_with(opts)}, :status => :moved_permanently
      else
        redirect_to build_url_path_method(opts), :status => :moved_permanently
      end
    end

    # redirect do indexu po uspesnem smazani
    def redirect_destroy_ok(*opts)
      if request.xhr?
        render :json => {:status => "ok", :message => I18n.t("activerecord.info.messages.deleted"), :settings => fill_settings_with(opts)}, :status => :moved_permanently
      else
        redirect_to build_url_path_method(opts), :status => :moved_permanently
      end
    end

    # redirect po uspesnem save
    def redirect_save_ok(*opts)
      if request.xhr?
        render :json => {:status => "ok", :message => I18n.t("activerecord.info.messages.saved"), :settings => fill_settings_with(opts)}, :status => :moved_permanently
      else
        redirect_to build_url_path_method(opts), :status => :moved_permanently
      end

    end

    # redirect po uspesnem save
    def redirect_save_failed(*opts)
      if request.xhr?
        render :json => {:status => "ok", :message => I18n.t("activerecord.errors.messages.save_failed"), :settings => fill_settings_with(opts)}, :status => :moved_permanently
      else
        redirect_to build_url_path_method(opts), :status => :moved_permanently
      end

    end
  end
end

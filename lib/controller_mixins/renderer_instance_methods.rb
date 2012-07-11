module ControllerMixins
  module RendererInstanceMethods
    def render_table_for(logged_user, template = nil, &proc)
      @settings[:template] = template unless template.blank?
      data = yield
      class_obj = data.respond_to?(:klass) ? data.klass : data
      if action_name == "filter"
        default_params = params
        default_params = @settings[:default] if !params.blank? && params["clear"]

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
      elsif action_name == "index"
        default_params = @settings[:default]
        default_params = session["#{@settings[:form_id]}_params"] unless session["#{@settings[:form_id]}_params"].blank?
        @settings = class_obj.prepare_settings(logged_user, data, @settings, default_params)
      end
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

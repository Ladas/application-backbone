module ViewMixins
  module Form

    def ajax_form_for(record, options = {}, &proc)
      raise ArgumentError, "Missing block" unless block_given?

      options[:html] ||= {}

      case record
        when String, Symbol
          object_name = record
          object = nil
        else
          object = record.is_a?(Array) ? record.last : record
          object_name = options[:as] || ActiveModel::Naming.param_key(object)
          apply_form_for_options!(record, options)
      end
      caller_id = options[:html][:id]
      options[:html][:remote] = options.delete(:remote) if options.has_key?(:remote)
      options[:html][:method] = options.delete(:method) if options.has_key?(:method)
      options[:html][:authenticity_token] = options.delete(:authenticity_token)
      ######### additional logic by ladas ##############
      #options[:html][:control_against_overwrite_by_another_user] = Time.now
      ################## end ###############3###########

      builder = options[:parent_builder] = instantiate_builder(object_name, object, options, &proc)
      fields_for = fields_for(object_name, object, options, &proc)
      default_options = builder.multipart? ? {:multipart => true} : {}
      output = form_tag(options.delete(:url) || {}, default_options.merge!(options.delete(:html)))
      ######### additional logic by ladas ##############
      if !object.blank? && !object.id.blank?
        output << "<fieldset><input type='hidden' name='#{ActiveModel::Naming.param_key(record)}[control_against_overwrite_by_another_user]' value='#{Time.now.utc}' /></fieldset>".html_safe
      end
      ################## end ###############3###########

      output << fields_for
      ######### additional logic by ladas ##############
      output.safe_concat(build_ajax_callback_code(caller_id))
      ################## end ###############3###########
      output.safe_concat('</form>')
    end


    def build_ajax_callback_code(caller_id)
      render :partial => '/helpers/build_ajax_callback_code', :layout => false, :locals => {:caller_id => caller_id}
    end

  end
end
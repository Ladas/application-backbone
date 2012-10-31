module ViewMixins
  module Table
    def editable_table_for(settings)
      #settings
      render :partial => '/helpers/editable_table/build_table', :layout => false, :locals => {:settings => settings}
    end

    def table_for(settings)
      #settings
      render :partial => '/helpers/build_table', :layout => false, :locals => {:settings => settings}
    end

    ##
    # Selected values from custom filter, it checks params and session
    ##
    def selected_values(form_id, path, default = [])
      par = params
      path.each do |p|
        break if par.blank?
        unless par[p.to_s].blank?
          par = par[p.to_s]
        else
          par = nil
        end
      end
      selected = par unless par.blank?

      if selected.blank?
        par = session[form_id+"_params"]

        path.each do |p|
          break if par.blank?
          unless par[p.to_s].blank?
            par = par[p.to_s]
          else
            par = nil
          end
        end
        selected = par
      end
      selected = selected.blank? ? default : selected

      selected
    end
  end
end
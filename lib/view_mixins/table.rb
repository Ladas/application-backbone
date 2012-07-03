module ViewMixins
  module Table
    def table_for(settings)
      #settings
      render :partial => '/helpers/build_table', :layout => false, :locals => {:settings => settings}
    end
  end
end
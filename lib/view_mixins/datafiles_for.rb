module ViewMixins
  module DatafilesFor
    def datafiles_for(object, tiny_mce_selector = ".datafile_tinymce", can_upload = true)
      render :partial => '/helpers/build_datafiles', :layout => false, :locals => {:object => object, :tiny_mce_selector => tiny_mce_selector, :can_upload => can_upload}
    end
  end
end
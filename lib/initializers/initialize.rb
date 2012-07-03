require 'view_mixins/link'
require 'view_mixins/form'
require 'view_mixins/breadcrumb'
require 'view_mixins/datafiles_for'
require 'view_mixins/table'

require 'model_mixins/table_builder_class_methods'
require 'model_mixins/tree_node_class_methods'
require 'model_mixins/tree_node_instance_methods'

require 'controller_mixins/renderer_instance_methods'

module Initializers
  class Initialize < Rails::Railtie
    initializer "initialize mixins" do
      ActionView::Base.send :include, ViewMixins::Link
      ActionView::Base.send :include, ViewMixins::Form
      ActionView::Base.send :include, ViewMixins::Breadcrumb
      ActionView::Base.send :include, ViewMixins::Table
      ActionView::Base.send :include, ViewMixins::DatafilesFor

      ActionController::Base.send :include, ControllerMixins::RendererInstanceMethods

      ActiveRecord::Base.send :extend, ModelMixins::TableBuilderClassMethods
      ActiveRecord::Base.send :extend, ModelMixins::TreeNodeInstanceMethods
      ActiveRecord::Base.send :extend, ModelMixins::TreeNodeClassMethods
    end
  end
end


# monkey patch for control of right timestamp when updating a model, in the case that somebody updatedd it in the time beetween show the form and update the form
# it will yell it was updated by another user
module ActiveRecord
  # = Active Record Persistence
  module Persistence

    def update_attributes(attributes, options = {})
      if timestamp_control = attributes.delete(:control_against_overwrite_by_another_user)
        if self.attributes['updated_at'] > timestamp_control
          errors[:base] << I18n.t('errors.messages.control_against_overwrite_by_another_user')
          return false
        end
      end
      with_transaction_returning_status do
        self.assign_attributes(attributes, options)
        save
      end
    end

    def update_attributes!(attributes, options = {})
      if timestamp_control = attributes.delete(:control_against_overwrite_by_another_user)
        if self.attributes['updated_at'] > timestamp_control
          errors[:base] << I18n.t('errors.messages.control_against_overwrite_by_another_user')
          return false
        end
      end
      with_transaction_returning_status do
        self.assign_attributes(attributes, options)
        save!
      end
    end

  end
end






#
#
#class ActiveRecord::Base
#  extend ModelMixins::TableBuilderClassMethods
#end
#
#module ApplicationHelper
#  include ViewMixins::Link
#  include ViewMixins::Form
#  include ViewMixins::Breadcrumb
#  include ViewMixins::Table
#end
#
#class ApplicationController
#  include ControllerMixins::RendererInstanceMethods
#end
#
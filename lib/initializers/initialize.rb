

class ActiveRecord::Base
  extend ModelMixins::TableBuilderClassMethods
end

module ApplicationHelper
  include ViewMixins::Link
  include ViewMixins::Form
  include ViewMixins::Breadcrumb
  include ViewMixins::Table
end

class ApplicationController
  include ControllerMixins::RendererInstanceMethods
end


# monkey patch for control of right timestamp when updating a model, in the case that somebody updatedd it in the time beetween show the form and update the form
# it will yell it was updated by another user
module ActiveRecord
  # = Active Record Persistence
  module Persistence

    def update_attributes(attributes, options = {})
      if timestamp_control = attributes.delete(:control_against_overwrite_by_another_user)
        if self.attributes['updated_at'] > timestamp_control
          errors[:base] << I18n.t('activerecord.errors.messages.control_against_overwrite_by_another_user')
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
          errors[:base] << I18n.t('activerecord.errors.messages.control_against_overwrite_by_another_user')
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
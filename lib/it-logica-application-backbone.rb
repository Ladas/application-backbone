module ItLogicaApplicationBackbone
  require 'backbone_js/engine'


  require 'view_mixins/link'
  require 'view_mixins/form'
  require 'view_mixins/breadcrumb'
  require 'view_mixins/table'

  require 'model_mixins/table_builder_class_methods'

  require 'controller_mixins/renderer_instance_methods'

  require 'initializers/initialize.rb' if defined?(Rails)

end
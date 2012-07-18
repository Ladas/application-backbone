module ViewMixins
  module Breadcrumb
    def breadcrumb_for(*args)
      # ToDo dodělat caching tohoto, invalidovat budu pokud nastane SAVE u OBJECT
      breadcrumb = []
      args.each do |object|
        if !object.blank?
          if is_tree_node?(object)
            tree_node = object
            unless tree_node.blank?
              bread_crumb_load_tree_recursive(breadcrumb, tree_node)
            end
          elsif object.respond_to?(:tree_nodes)
            if !object.tree_nodes.blank? && !object.tree_nodes.first.blank? && is_tree_node?(object.tree_nodes.first)
              tree_node = object.tree_nodes.first if !object.tree_nodes.blank? && !object.tree_nodes.first.blank?
              unless tree_node.blank?
                bread_crumb_load_tree_recursive(breadcrumb, tree_node)
              end
            end
          elsif object.kind_of?(Hash)
            breadcrumb << object
          elsif object.kind_of?(Array)
            object.each do |o|
              breadcrumb << o
            end
          end
        end
      end
      render :partial => '/helpers/build_breadcrumb', :layout => false, :locals => {:breadcrumb => breadcrumb}
    end

    def bread_crumb_load_tree_recursive(breadcrumb, tree_node)
      unless tree_node.blank?
        if tree_node.parent_node_id > 0
          bread_crumb_load_tree_recursive(breadcrumb, tree_node.parent_node)
        end
        breadcrumb << tree_node
      end
    end

    def is_tree_node?(object)
      if defined?(Intranet::TreeNode) == 'constant' && Intranet::TreeNode.class == Class
        #object.kind_of?(Intranet::TreeNode) #|| object.kind_of?(Web::TreeNode) || object.kind_of?(Organizer::TreeNode)
        return object.kind_of?(Intranet::TreeNode)
      end
      false
    end
  end
end
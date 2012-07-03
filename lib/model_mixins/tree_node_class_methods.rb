module ModelMixins
  module TreeNodeClassMethods
    def child_nodes(id)
      where(:parent_node_id => id.to_i).order("position ASC")
    end


    def get_children(id)
      nodes = []
      self.child_nodes(id).each do |tree_node|
        tree_node_name = tree_node.name.blank? ? I18.t('name_missing') : tree_node.name
        tree_node_state = tree_node.has_children? ? "closed" : ""
        nodes << {:attr => {:id => tree_node.id, :rel => "default", "data-settings" => tree_node.to_json}, :data => tree_node_name, :state => tree_node_state}
      end
      nodes
    end

    def search_node

    end

    def create_node(params)
      node = self.create(:parent_node_id => params['id'].to_i, :position => params['position'].to_i, :name => params['title'])

      {:status => "ok", :id => node.id, "data-settings" => node.to_json}
    end


    def remove_node(id)
      node = self.find(id)
      node.deleting_root = true
      node.remove_child_nodes

      {:status => "ok"}
    end

    def rename_node(params)
      node = self.find(params['id'].to_i)
      node.name = params['title']
      node.save

      {:status => "ok"}
    end

    def move_node(params)
      node = self.find(params['id'].to_i)

      # backup for control if something changed
      node.old_position = node.position
      node.old_parent_node_id = node.parent_node_id

      if params['ref'].to_i == 0
        #root
        node.parent_node_id = 0
      else
        new_parent_node = self.find(params['ref'].to_i)
        node.parent_node = new_parent_node
      end
      node.position = params['position'].to_i
      node.save

      {:status => "ok"}
    end


  end
end
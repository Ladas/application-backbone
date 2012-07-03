module ModelMixins
  module TreeNodeInstanceMethods
    extend ActiveSupport::Concern

    included do
      attr_accessible :symlink_controller, :symlink_action, :symlink_id, :symlink_params, :symlink_subdomain, :resource_type, :resource_id, :symlink_remote, :symlink_new_tab
      attr_accessible :name, :parent_node_id, :position
      attr_accessor :old_position, :old_parent_node_id, :deleting_root

      belongs_to :resource, :polymorphic => true, :dependent => :destroy

      #belongs_to :parent_node , :class_name => "Intranet::TreeNode"
      belongs_to :parent_node, :class_name => "TreeNode"


      before_create :create_resource

      before_save :set_positions_after_move
      before_destroy :set_positions_after_destroy
    end

    def create_resource
      if self.symlink_controller.blank?
        node_resource = Intranet::TextPage.create(:name => self.name)
        self.resource = node_resource
        self.symlink_controller = "text_pages"
        self.symlink_id = node_resource.id.to_s
      end
    end

    def set_positions_after_move
      if !old_position.blank? && !old_parent_node_id.blank?
        self.class.child_nodes(old_parent_node_id).where("position > ?", old_position).each do |node|
          node.position -= 1
          node.save
        end
        self.class.child_nodes(parent_node_id).where("position >= ?", position).each do |node|
          node.position += 1
          node.save
        end
      end
    end

    def set_positions_after_destroy
      if !deleting_root.blank? && deleting_root
        self.class.child_nodes(parent_node_id).where("position > ?", position).each do |node|
          node.position -= 1
          node.save
        end
      end
    end


    def child_nodes
      self.class.child_nodes(self.id)
    end

    def has_children?
      self.class.child_nodes(self.id).count > 0
    end


    def remove_child_nodes
      if has_children?
        child_nodes.each do |child_node|
          child_node.remove_child_nodes
        end
      end
      remove_one_node
    end

    def remove_one_node
      destroy
    end
  end
end
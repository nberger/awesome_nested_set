# Enables parent_column centric interface.
module CollectiveIdea #:nodoc:
  module Acts #:nodoc:
    module NestedSet #:nodoc:
      module ParentColumnCentric
        def self.included(base)
          base.before_save :get_previous_parent_id
          base.after_save :move_to_parent
        end

        def roots
          self.class.find(:all, :conditions => "#{quoted_parent_column_name} is null", :order => "lft")
        end

        private
        def get_previous_parent_id
          @previous_parent_id = new_record? ? nil : self.class.find(self.id)[parent_column_name]
        end

        def move_to_parent
          return if @previous_parent_id == self[parent_column_name]

          # If parent_id has been changed, move the element.
          if self[parent_column_name].nil?
            # Going to be the last root
            move_to_right_of((roots - [self]).last)
          else
            # Going to be a child of the specified parent
            raise "no parent for #{self[parent_column_name]}" unless parent
            move_to_child_of parent
          end
        end
      end
    end
  end
end
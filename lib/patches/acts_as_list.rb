# Provides Rails 4 compatibility patches for acts_as_list.
#
# We can't use https://github.com/swanandp/acts_as_list,
# because it breaks the cell feature and it does not have a gem on rubygems.
#
ActiveRecord::Acts::List::InstanceMethods.module_eval do

  # Removes the item from the list.
  def remove_from_list
    if in_list?
      decrement_positions_on_lower_items
      update_column position_column, nil
    end
  end

  # Increase the position of this item without adjusting the rest of the list.
  def increment_position
    return unless in_list?
    update_column position_column, self.send(position_column).to_i + 1
  end

  # Decrease the position of this item without adjusting the rest of the list.
  def decrement_position
    return unless in_list?
    update_column position_column, self.send(position_column).to_i - 1
  end

  private

    # Forces item to assume the bottom position in the list.
    def assume_bottom_position
      update_column(position_column, bottom_position_in_list(self).to_i + 1)
    end

    # Forces item to assume the top position in the list.
    def assume_top_position
      update_column(position_column, acts_as_list_top)
    end

    def insert_at_position(position)
      if in_list?
        old_position = send(position_column).to_i
        return if position == old_position
        shuffle_positions_on_intermediate_items(old_position, position)
      else
        increment_positions_on_lower_items(position)
      end
      self.update_column(position_column, position)
    end

    # used by insert_at_position instead of remove_from_list, as postgresql raises error if position_column has non-null constraint
    def store_at_0
      if in_list?
        old_position = send(position_column).to_i
        update_column(position_column, 0)
        decrement_positions_on_lower_items(old_position)
      end
    end

end

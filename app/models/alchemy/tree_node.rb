# frozen_string_literal: true

# Represents a node in the admin page tree
#
# Used by page reorder
#
Alchemy::TreeNode = Struct.new(:left, :right, :parent, :depth, :url, :restricted)

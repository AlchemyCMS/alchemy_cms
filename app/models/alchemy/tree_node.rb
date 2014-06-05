module Alchemy
  class TreeNode < Struct.new(:left, :right, :parent, :depth, :url, :restricted)
      extend NameConversions
  end
end

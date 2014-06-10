module Alchemy
  class TreeNode < Struct.new(:left, :right, :parent, :depth, :url, :restricted)
  end
end
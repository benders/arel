module Arel
  module Nodes
    class Select
      attr_reader :froms, :projections, :wheres

      def initialize
        @froms       = []
        @projections = []
        @wheres      = []
      end
    end
  end
end
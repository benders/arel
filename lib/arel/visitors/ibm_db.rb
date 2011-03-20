# +-----------------------------------------------------------------------+
# | |
# | Copyright (c) 2011 IBM Corporation |
# | |
# | Permission is hereby granted, free of charge, to any person obtaining |
# | a copy of this software and associated documentation files (the |
# | "Software"), to deal in the Software without restriction, including |
# | without limitation the rights to use, copy, modify, merge, publish, |
# | distribute, sublicense, and/or sell copies of the Software, and to |
# | permit persons to whom the Software is furnished to do so, subject to |
# | the following conditions: |
# | |
# | The above copyright notice and this permission notice shall be |
# | included in all copies or substantial portions of the Software. |
# | |
# | THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, |
# | EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF |
# | MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
# | IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR |
# | ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION |
# | OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION |
# | WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. |
# | |
# +-----------------------------------------------------------------------+

#
#  Author: Praveen Devarao <praveendrl@in.ibm.com>
#

module Arel
  module Visitors
    class IbmDB < Arel::Visitors::ToSql
      def visit_Arel_Nodes_SelectStatement o
        limit = offset = nil
        sqlSegment = [
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join,
          ("ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?),
        ].compact.join ' '

        # Add limit offset segments
        limit = o.limit.expr if o.limit
        offset = o.offset.expr if o.offset
        @engine.connection.add_limit_offset!(sqlSegment,{:limit=>limit,:offset=>offset})

        # Append lock clause and join
        [ sqlSegment,
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end
    end
  end
end

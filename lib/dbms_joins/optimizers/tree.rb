# frozen_string_literal: true

# rubocop:disable Style/Documentation
module DbmsJoins
  # A join between two relations or joins.
  # Can conviniently be used for constructing join trees.
  class Join
    def initialize(left, right)
      @left = ensure_relation(left)
      @right = ensure_relation(right)
    end

    def joins?(input1, input2)
      ((input1.relations - left_relations == []) && (input2.relations - right_relations == [])) ||
        ((input2.relations - left_relations == []) && (input1.relations - right_relations == []))
    end

    def size
      relations.size
    end

    def relations
      left_relations + right_relations
    end

    def left_relations
      @left.is_a?(Join) ? @left.relations : [@left]
    end

    def right_relations
      @right.is_a?(Join) ? @right.relations : [@right]
    end

    def to_s
      "(#{@left}, #{@right})"
    end

    def linear?
      (@left.is_a?(Relation) && @left.is_a?(Relation)) ||
        (@left.is_a?(Relation) && @right.linear?) ||
        (@left.linear? && @right.is_a?(Relation))
    end

    private

    def ensure_relation(relation)
      if relation.is_a?(Relation) || relation.is_a?(Join)
        relation
      else
        Relation.new(relation)
      end
    end
  end

  # A relation for construction of join trees.
  class Relation
    def initialize(val)
      @val = val
    end

    def joins?(_input1, _input2)
      false
    end

    def size
      1
    end

    def relations
      [self]
    end

    def to_s
      @val
    end
  end

  def self.joins?(query, input1, input2)
    query.predicates.each do |predicate|
      return true if
        input1.relations.include?(predicate[0]) && input2.relations.include?(predicate[1]) ||
        input1.relations.include?(predicate[1]) && input2.relations.include?(predicate[0])
    end
  end
end
# rubocop:enable Style/Documentation

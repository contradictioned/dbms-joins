# frozen_string_literal: true

module DbmsJoins
  # This "optimizer" creates a random bushy tree.
  #
  # By default it won't create a linear tree
  # or a tree with cross products allowed.
  # :reek:Attribute
  # :reek:InstanceVariableAssumption
  # :reek:TooManyInstanceVariables
  class RandomBushy
    attr_accessor :linear_allowed, :crossproducts_allowed
    def initialize
      @linear_allowed = false
      @crossproducts_allowed = false
    end

    # rubocop:disable Metrics/MethodLength
    def optimize(query)
      return nil if DbmsJoins.star? query

      @query = query
      @relations = query.relations
      @predicates = query.predicates
      return nil if @relations.size <= 3

      @result = @relations.map { |rel| DbmsJoins::Relation.new(rel) }

      start_join = pick_start_join
      replace_in_result start_join

      while @result.size != 1
        next_join = find_smallest_joinable_pair
        replace_in_result next_join
      end

      @result.first
    end
    # rubocop:enable Metrics/MethodLength

    def pick_start_join
      relations = DbmsJoins.relations_used_by_exactly_one_predicate @relations, @predicates
      predicate = if relations.empty?
                    @predicates.sample
                  else
                    DbmsJoins.predicates_for_relation(relations.sample, @predicates).first
                  end
      Join.new(predicate[0], predicate[1])
    end

    # rubocop:disable Metrics/MethodLength
    # :reek:NestedIterators
    def replace_in_result(join)
      left_idx = -1
      right_idx = -1
      @result.each_with_index do |r1, idx1|
        @result.each_with_index do |r2, idx2|
          next if idx1 >= idx2

          if join.joins? r1, r2
            left_idx = idx1
            right_idx = idx2
          end
        end
      end
      @result.delete_at(right_idx)
      @result.delete_at(left_idx)
      @result << join
    end
    # rubocop:enable Metrics/MethodLength

    # A joinable pair is a pair of relations or join trees.
    # Small refers to the total number of involved relations.
    # If multiple joinable pairs are found with same size, a random one is picked.
    # :reek:FeatureEnvy
    def find_smallest_joinable_pair
      candidates = find_all_joinable_pairs
      min = candidates.min_by(&:size).size
      result = candidates.select { |tree| tree.size == min }.sample
      result
    end

    # :reek:FeatureEnvy
    def find_all_joinable_pairs
      @result
        .combination(2)
        .filter { |pair| DbmsJoins.joins? @query, pair[0], pair[1] }
        .map { |pair| Join.new(pair[0], pair[1]) }
    end
  end
end

# frozen_string_literal: true

module DbmsJoins
  # DataCharacteristics comprise of relation sizes and selectivities
  # for joins between relations.
  #
  # For this gem, a DataCharacteristics object also encodes a query:
  # - if a size for a relation is defined, the relation is queried,
  # - if the selectivity for two relations is not 1.0, a predicate is
  #   defined between them.
  #
  class DataCharacteristics
    def initialize(sizes = {}, selectivities = {})
      @sizes = sizes
      @selectivities = selectivities
    end

    def relations
      @sizes.keys
    end

    # :reek:NestedIterators
    def predicates
      result = []
      @selectivities.each_pair do |relation_a, inner|
        inner.keys.each do |relation_b|
          result << [relation_a, relation_b]
        end
      end
      result
    end

    def joins?(relation_a, relation_b)
      selectivity(relation_a, relation_b) < 1.0
    end

    def size(relation)
      @sizes[relation]
    end

    def add_size(relation, size)
      @sizes[relation] = size
    end

    def selectivity(relation_a, relation_b)
      relation_a, relation_b = [relation_a, relation_b].sort
      @selectivities.dig(relation_a, relation_b) || 1.0
    end

    def add_selectivity(relation_a, relation_b, selectivity)
      relation_a, relation_b = [relation_a, relation_b].sort

      @selectivities[relation_a] ||= {}
      @selectivities[relation_a][relation_b] = selectivity
    end

    # Constructs a new query by projecting this query
    # to the provided relations
    # :reek:FeatureEnvy
    # :reek:NestedIterators
    def sub_query(relations)
      sizes = @sizes.select { |k, _| relations.include? k }
      selectivities = @selectivities.select { |k, _| relations.include? k }
      selectivities.transform_values! { |v| v.select { |k, _| relations.include? k } }

      DataCharacteristics.new(sizes, selectivities)
    end
  end
end

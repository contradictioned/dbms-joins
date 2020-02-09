# frozen_string_literal: true

# rubocop:disable Style/Documentation
module DbmsJoins
  # Returns true, iff the query is a linear one.
  # I.e., the relations can be ordered like R1, R2, R3, ...
  # and all predicates are defined only between relations Ri and R(i+1)
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.linear?(query)
    candidates = relations_used_by_exactly_one_predicate query.relations, query.predicates
    return false if candidates.size != 2

    current_relation = candidates.first
    current_predicate = predicates_for_relation(current_relation, query.predicates).first
    next_relation = current_predicate.find { |relation| relation != current_relation }
    query = query.sub_query(query.relations.delete(current_relation))

    while query.relations.size > 2
      current_relation = next_relation
      current_predicates = predicates_for_relation(current_relation, query.predicates)
      return false if current_predicates.size != 1

      current_predicate = current_predicates.first
      next_relation = current_predicate.delete(current_relation).first
      query = query.sub_query(query.relations.delete(current_relation))
    end
    true
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # Returns true, iff the query forms a complete graph.
  # I.e., each relation has a predicate with each other relation.
  # :reek:NestedIterators
  def self.complete?(query)
    relations = query.relations
    relations.each do |relation|
      expected = relations.filter { |inner| inner > relation }
      return false if expected.any? { |inner| !query.joins?(relation, inner) }
    end
    true
  end

  # Returns true, iff the query is a star query.
  # I.e., there is exactly one relation "in the middle"
  # and all other relations join with this one.
  def self.star?(query)
    relations_used_by_all_predicates(query.relations, query.predicates).size >= 1
  end

  # Returns nil if no such relation is found
  def self.relations_used_by_all_predicates(relations, predicates)
    relations.select { |relation| predicates_for_relation(relation, predicates) == predicates }
  end

  # Returns nil if no such relation is found
  def self.relation_used_by_exactly_one_predicate(relations, predicates)
    relations_used_by_exactly_one_predicate(relations, predicates).first
  end

  def self.relations_used_by_exactly_one_predicate(relations, predicates)
    relations.select { |relation| predicates_for_relation(relation, predicates).size == 1 }
  end

  def self.predicates_for_relation(relation, predicates)
    predicates.select { |predicate| predicate.include? relation }
  end
end
# rubocop:enable Style/Documentation

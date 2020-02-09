# frozen_string_literal: true

RSpec.describe DbmsJoins do
  context 'identifying linear queries' do
    it 'identifies linear query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_selectivity 'R', 'S', 0.3

      expect(DbmsJoins.linear?(query)).to be true
    end

    it 'identifies linear query, example 2' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 300
      query.add_size 'U', 400
      query.add_selectivity 'R', 'T', 0.3
      query.add_selectivity 'T', 'S', 0.2
      query.add_selectivity 'S', 'U', 0.1

      expect(DbmsJoins.linear?(query)).to be true
    end

    it 'identifies linear query, example 3' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 300
      query.add_size 'U', 400
      query.add_selectivity 'R', 'S', 0.3
      query.add_selectivity 'T', 'S', 0.2
      query.add_selectivity 'T', 'U', 0.1

      expect(DbmsJoins.linear?(query)).to be true
    end

    it 'identifies non-linear query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200

      expect(DbmsJoins.linear?(query)).to be false
    end

    it 'identifies non-linear query, example 2' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 300
      query.add_size 'U', 400
      query.add_selectivity 'R', 'S', 0.3
      query.add_selectivity 'S', 'T', 0.2
      query.add_selectivity 'T', 'R', 0.1
      query.add_selectivity 'S', 'U', 0.1

      expect(DbmsJoins.linear?(query)).to be false
    end
  end

  context 'identifying complete queries' do
    it 'identifies complete query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_selectivity 'R', 'S', 0.3

      expect(DbmsJoins.complete?(query)).to be true
    end

    it 'identifies complete query, example 2' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 200
      query.add_selectivity 'R', 'S', 0.3
      query.add_selectivity 'R', 'T', 0.3
      query.add_selectivity 'S', 'T', 0.3

      expect(DbmsJoins.complete?(query)).to be true
    end

    it 'identifies non-complete query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 200
      query.add_selectivity 'R', 'S', 0.3
      query.add_selectivity 'S', 'T', 0.3

      expect(DbmsJoins.complete?(query)).to be false
    end
  end

  context 'identifying star queries' do
    it 'identifies star query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_selectivity 'R', 'S', 0.3

      expect(DbmsJoins.star?(query)).to be true
    end

    it 'identifies star query, example 2' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 10
      query.add_size 'T', 20
      query.add_size 'U', 30
      query.add_selectivity 'R', 'S', 0.1
      query.add_selectivity 'R', 'T', 0.1
      query.add_selectivity 'R', 'U', 0.1

      expect(DbmsJoins.star?(query)).to be true
    end

    it 'identifies non-star query, example 1' do
      query = DbmsJoins::DataCharacteristics.new
      query.add_size 'R', 100
      query.add_size 'S', 200
      query.add_size 'T', 200
      query.add_selectivity 'R', 'S', 0.3
      query.add_selectivity 'S', 'T', 0.3
      query.add_selectivity 'R', 'T', 0.3

      expect(DbmsJoins.star?(query)).to be false
    end
  end

  it 'finds relations used by all predicates' do
    relations = ['A', 'B', 'C', 'D']

    predicates_a = [['A', 'B'], ['A', 'C'], ['A', 'D']]
    result_a = DbmsJoins.relations_used_by_all_predicates relations, predicates_a
    expect(result_a).not_to be nil
    expect(result_a).to eq ['A']

    predicates_b = [['A', 'D'], ['B', 'D'], ['C', 'D']]
    result_b = DbmsJoins.relations_used_by_all_predicates relations, predicates_b
    expect(result_b).not_to be nil
    expect(result_b).to eq ['D']

    predicates_c = [['A', 'B'], ['A', 'C'], ['A', 'D'], ['B', 'D']]
    result_c = DbmsJoins.relations_used_by_all_predicates relations, predicates_c
    expect(result_c).not_to be nil
    expect(result_c).to eq []

    predicates_d = [['A', 'B']]
    result_d = DbmsJoins.relations_used_by_all_predicates relations, predicates_d
    expect(result_d).not_to be nil
    expect(result_d).to eq ['A', 'B']
  end

  it 'finds relations used by exactly one predicate' do
    relations = ['A', 'B', 'C', 'D']

    predicates_a = [['A', 'C'], ['B', 'C'], ['B', 'D'], ['C', 'D']]
    result_a = DbmsJoins.relation_used_by_exactly_one_predicate relations, predicates_a
    expect(result_a).not_to be nil
    expect(result_a).to eq 'A'

    predicates_b = [['A', 'C'], ['A', 'D'], ['B', 'D'], ['C', 'D']]
    result_b = DbmsJoins.relation_used_by_exactly_one_predicate relations, predicates_b
    expect(result_b).not_to be nil
    expect(result_b).to eq 'B'

    predicates_c = [['A', 'B'], ['A', 'C'], ['A', 'D'], ['B', 'D']]
    result_c = DbmsJoins.relation_used_by_exactly_one_predicate relations, predicates_c
    expect(result_c).not_to be nil
    expect(result_c).to eq 'C'

    predicates_d = [['A', 'B'], ['A', 'C'], ['B', 'C'], ['C', 'D']]
    result_d = DbmsJoins.relation_used_by_exactly_one_predicate relations, predicates_d
    expect(result_d).not_to be nil
    expect(result_d).to eq 'D'
  end

  it 'returns nil if no relation is used by exactly one predicate' do
    relations = ['A', 'B', 'C']
    predicates = [['A', 'B'], ['A', 'C'], ['B', 'C']]
    result = DbmsJoins.relation_used_by_exactly_one_predicate relations, predicates
    expect(result).to be nil
  end

  it 'lists predicates for a relation correctly' do
    predicates = [['A', 'B'], ['A', 'C'], ['B', 'C'], ['B', 'D'], ['D', 'E']]

    expect(DbmsJoins.predicates_for_relation('A', predicates))
      .to contain_exactly(['A', 'B'], ['A', 'C'])

    expect(DbmsJoins.predicates_for_relation('B', predicates))
      .to contain_exactly(['A', 'B'], ['B', 'C'], ['B', 'D'])

    expect(DbmsJoins.predicates_for_relation('C', predicates))
      .to contain_exactly(['A', 'C'], ['B', 'C'])

    expect(DbmsJoins.predicates_for_relation('D', predicates))
      .to contain_exactly(['B', 'D'], ['D', 'E'])

    expect(DbmsJoins.predicates_for_relation('E', predicates))
      .to contain_exactly(['D', 'E'])
  end
end

# frozen_string_literal: true

RSpec.describe DbmsJoins::RandomBushy do
  it 'creates a bushy tree' do
    query = DbmsJoins::DataCharacteristics.new
    query.add_size 'R', 100
    query.add_size 'S', 200
    query.add_size 'T', 200
    query.add_size 'U', 200
    query.add_selectivity 'R', 'S', 0.3
    query.add_selectivity 'S', 'T', 0.3
    query.add_selectivity 'R', 'T', 0.3
    query.add_selectivity 'R', 'U', 0.3

    result = DbmsJoins::RandomBushy.new.optimize(query)
    expect(result).to_not satisfy(&:linear?)
  end
end

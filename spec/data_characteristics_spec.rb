# frozen_string_literal: true

RSpec.describe DbmsJoins::DataCharacteristics do
  it 'registers size' do
    dc = DbmsJoins::DataCharacteristics.new

    dc.add_size 'R', 500
    dc.add_size 'S', 300
    expect(dc.size('R')).not_to be nil
    expect(dc.size('R')).to be 500
    expect(dc.size('S')).not_to be nil
    expect(dc.size('S')).to be 300
    expect(dc.size('T')).to be nil
  end

  it 'registers selectivities' do
    dc = DbmsJoins::DataCharacteristics.new

    dc.add_selectivity 'R', 'S', 0.2

    expect(dc.selectivity('R', 'S')).not_to be nil
    expect(dc.selectivity('R', 'S')).to be 0.2
    expect(dc.selectivity('S', 'R')).not_to be nil
    expect(dc.selectivity('S', 'R')).to be 0.2
  end

  it 'returns 1.0 for unset selectivities' do
    dc = DbmsJoins::DataCharacteristics.new

    dc.add_selectivity 'R', 'S', 0.2

    expect(dc.selectivity('R', 'T')).not_to be nil
    expect(dc.selectivity('R', 'T')).to be 1.0
    expect(dc.selectivity('U', 'V')).not_to be nil
    expect(dc.selectivity('U', 'V')).to be 1.0
  end

  it 'tells the correct relations' do
    dc = DbmsJoins::DataCharacteristics.new

    dc.add_size 'R', 500
    dc.add_size 'S', 300

    expect(dc.relations).to contain_exactly('R', 'S')
  end

  it 'tells the correct selectivities' do
    dc = DbmsJoins::DataCharacteristics.new

    dc.add_selectivity 'R', 'S', 0.2
    dc.add_selectivity 'S', 'T', 0.3

    expect(dc.predicates).to contain_exactly(['R', 'S'], ['S', 'T'])
  end

  it 'produces sub_query' do
    dc = DbmsJoins::DataCharacteristics.new
    dc.add_size 'R', 100
    dc.add_size 'S', 200
    dc.add_size 'T', 300
    dc.add_size 'U', 400

    dc.add_selectivity 'R', 'S', 0.1
    dc.add_selectivity 'R', 'T', 0.2
    dc.add_selectivity 'S', 'T', 0.3
    dc.add_selectivity 'S', 'U', 0.4
    dc.add_selectivity 'T', 'U', 0.6

    sq1 = dc.sub_query(['R', 'S', 'T'])
    expect(sq1.relations).to contain_exactly('R', 'S', 'T')
    expect(sq1.predicates).to contain_exactly(['R', 'S'], ['R', 'T'], ['S', 'T'])

    sq2 = dc.sub_query(['R', 'S'])
    expect(sq2.relations).to contain_exactly('R', 'S')
    expect(sq2.predicates).to contain_exactly(['R', 'S'])

    sq3 = dc.sub_query(['T', 'U'])
    expect(sq3.relations).to contain_exactly('T', 'U')
    expect(sq3.predicates).to contain_exactly(['T', 'U'])
  end
end

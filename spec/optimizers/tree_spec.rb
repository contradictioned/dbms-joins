# frozen_string_literal: true

RSpec.describe DbmsJoins::Join do
  it 'collects relations correctly' do
    r = DbmsJoins::Relation.new('R')
    s = DbmsJoins::Relation.new('S')
    t = DbmsJoins::Relation.new('T')
    j = DbmsJoins::Join.new(DbmsJoins::Join.new(r, s), t)

    expect(j.left_relations).to contain_exactly(r, s)
    expect(j.right_relations).to contain_exactly(t)
  end

  it 'joins is correct' do
    r = DbmsJoins::Relation.new('R')
    s = DbmsJoins::Relation.new('S')
    j = DbmsJoins::Join.new(r, s)

    expect(j.joins?(r, s)).to be true
    expect(j.joins?(s, r)).to be true
  end

  it 'detects linear trees' do
    r = DbmsJoins::Relation.new('R')
    s = DbmsJoins::Relation.new('S')
    t = DbmsJoins::Relation.new('T')
    j = DbmsJoins::Join.new(DbmsJoins::Join.new(r, s), t)

    expect(j).to satisfy(&:linear?)
  end

  it 'detects non-linear trees' do
    r = DbmsJoins::Relation.new('R')
    s = DbmsJoins::Relation.new('S')
    t = DbmsJoins::Relation.new('T')
    u = DbmsJoins::Relation.new('U')
    j = DbmsJoins::Join.new(DbmsJoins::Join.new(r, s), DbmsJoins::Join.new(t, u))

    expect(j).to_not satisfy(&:linear?)
  end
end

RSpec.describe Api::V2::GreenLanes::MeasurePresenter do
  subject { described_class.new(measure) }

  let :measure do
    create :measure,
           :with_footnote_association,
           :with_goods_nomenclature,
           :with_measure_conditions
  end

  let(:footnotes) { measure.footnotes }

  it { is_expected.to have_attributes id: measure.measure_sid }
  it { is_expected.to have_attributes footnotes: }
  it { is_expected.to have_attributes footnote_ids: footnotes.map(&:code) }
  it { is_expected.to have_attributes goods_nomenclature_id: measure.goods_nomenclature.goods_nomenclature_sid }
  it { is_expected.to have_attributes measure_condition_ids: measure.measure_conditions.map(&:measure_condition_sid) }
end

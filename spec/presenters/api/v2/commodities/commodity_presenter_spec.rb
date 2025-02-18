RSpec.describe Api::V2::Commodities::CommodityPresenter do
  subject(:presenter) do
    described_class.new(commodity.reload, MeasureCollection.new(measures))
  end

  let(:commodity) do
    create(
      :commodity,
      :with_indent,
      :with_chapter_and_heading,
      :with_description,
      :declarable,
    )
  end

  describe '#third_country_measures' do
    let(:non_mfn_measure) do
      create(
        :measure,
        :with_measure_components,
        :with_measure_type,
      )
    end

    let(:zero_mfn_measure) { create(:measure, :mfn, duty_amount: 0) }
    let(:measures) { [non_mfn_measure, zero_mfn_measure] }

    it { expect(presenter.third_country_measures).to eq([zero_mfn_measure]) }
  end

  describe '#zero_mfn_duty?' do
    let(:zero_mfn_measure) { create(:measure, :mfn, duty_amount: 0) }
    let(:non_zero_mfn_measure) { create(:measure, :mfn, duty_amount: 1) }

    context 'when all mfn duties are zero' do
      let(:measures) { [zero_mfn_measure, zero_mfn_measure] }

      it { is_expected.to be_zero_mfn_duty }
    end

    context 'when at least one mfn duty is non-zero' do
      let(:measures) { [zero_mfn_measure, non_zero_mfn_measure] }

      it { is_expected.not_to be_zero_mfn_duty }
    end

    context 'when no mfn duty is zero' do
      let(:measures) { [non_zero_mfn_measure, non_zero_mfn_measure] }

      it { is_expected.not_to be_zero_mfn_duty }
    end

    context 'when no mfn duties are passed' do
      let(:measures) { [] }

      it { is_expected.not_to be_zero_mfn_duty }
    end
  end

  describe '#entry_price_system?' do
    before do
      allow(TradeTariffBackend).to receive(:service).and_return(service)
    end

    let(:entry_price_measure) { create(:measure, :with_measure_conditions, :with_entry_price_system) }
    let(:non_entry_price_measure) { create(:measure, :with_measure_conditions, :without_entry_price_system) }

    context 'when on the uk service' do
      let(:service) { 'uk' }

      let(:measures) { [entry_price_measure, non_entry_price_measure] }

      it { is_expected.not_to be_entry_price_system }
    end

    context 'when one of the measures uses the entry price system and on the xi service' do
      let(:service) { 'xi' }
      let(:measures) { [entry_price_measure, non_entry_price_measure] }

      it { is_expected.to be_entry_price_system }
    end

    context 'when none of the measures uses the entry price system and on the xi service' do
      let(:service) { 'xi' }
      let(:measures) { [non_entry_price_measure] }

      it { is_expected.not_to be_entry_price_system }
    end
  end

  describe '#special_nature?' do
    let(:presenter) { described_class.new(commodity.reload, measure_collection) }

    let(:measures_special_nature) do
      create_list(
        :measure, 1,
        :with_measure_conditions,
        :with_special_nature,
        goods_nomenclature_sid: commodity.goods_nomenclature_sid,
        geographical_area_id: 'PK'
      )
    end

    let(:measures_not_special_nature) do
      create_list(
        :measure, 1,
        :with_measure_conditions,
        goods_nomenclature_sid: commodity.goods_nomenclature_sid,
        geographical_area_id: 'CN'
      )
    end

    context 'when filtering by country' do
      let(:geographical_area_id) { 'CN' }

      context 'when commodity has at least one measure condition containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures_special_nature, geographical_area_id: }

        it { expect(presenter.special_nature?(measures_special_nature.first)).to eq(true) }
      end

      context 'when commodity does not have any measure conditions containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures_not_special_nature, geographical_area_id: }

        it { expect(presenter.special_nature?(measures_not_special_nature.first)).to eq(false) }
      end
    end

    context 'when not filtering by country' do
      let(:geographical_area_id) { nil }

      context 'when commodity has at least one measure condition containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures, geographical_area_id: }

        let(:measures) do
          create_list(
            :measure, 1,
            :with_measure_conditions,
            :with_special_nature,
            goods_nomenclature_sid: commodity.goods_nomenclature_sid,
            geographical_area_id: 'PK'
          )
        end

        it { expect(presenter.special_nature?(measures.first)).to eq(true) }
      end

      context 'when commodity does not have any measure conditions containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures, geographical_area_id: }

        let(:measures) do
          create_list(
            :measure, 1,
            :with_measure_conditions,
            goods_nomenclature_sid: commodity.goods_nomenclature_sid,
            geographical_area_id: 'PK'
          )
        end

        it { expect(presenter.special_nature?(measures.first)).to eq(false) }
      end

      context 'when commodity has some non country specific measure conditions containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures_not_special_nature + measures_special_nature, geographical_area_id: }

        it { expect(presenter.special_nature?(measures_not_special_nature.first)).to eq(false) }
      end

      context 'when commodity has some country specific measure conditions containing special nature certificate' do
        let(:measure_collection) { MeasureCollection.new measures_not_special_nature + measures_special_nature, geographical_area_id: }

        it { expect(presenter.special_nature?(measures_special_nature.first)).to eq(true) }
      end
    end
  end

  describe '#authorised_use_provisions_submission?' do
    context 'when filtering by country' do
      subject { described_class.new(commodity.reload, measure_collection) }

      let(:measure_collection) { MeasureCollection.new measures, geographical_area_id: 'CN' }

      context 'when commodity has at least one measure with authorised use submissions measure type id' do
        let(:measures) { create_list(:measure, 1, :with_authorised_use_provisions_submission) }

        it { is_expected.to be_authorised_use_provisions_submission }
      end

      context 'when commodity does not have any measures with authorised use submissions measure type id' do
        let(:measures) { create_list(:measure, 1) }

        it { is_expected.not_to be_authorised_use_provisions_submission }
      end
    end

    context 'when not filtering by country' do
      context 'when commodity has at least one measure with authorised use submissions measure type id' do
        let(:measures) { create_list(:measure, 1, :with_authorised_use_provisions_submission) }

        it { is_expected.not_to be_authorised_use_provisions_submission }
      end

      context 'when commodity does not have any measures with authorised use submissions measure type id' do
        let(:measures) { create_list(:measure, 1) }

        it { is_expected.not_to be_authorised_use_provisions_submission }
      end
    end
  end

  describe '#filtering_by_country?' do
    subject { described_class.new(commodity.reload, measure_collection) }

    let(:measure_collection) { MeasureCollection.new [], geographical_area_id: }

    context 'with country filtering' do
      let(:geographical_area_id) { 'CN' }

      it { is_expected.to be_filtering_by_country }
    end

    context 'without country filtering' do
      let(:geographical_area_id) { nil }

      it { is_expected.not_to be_filtering_by_country }
    end
  end

  describe '#ancestors' do
    subject { described_class.new(commodity, MeasureCollection.new([])).ancestors }

    let(:commodity) { subheading.children.first }
    let(:subheading) { create :subheading, :with_chapter_and_heading, :with_children }

    it { is_expected.to eq_pk [subheading] }
  end
end

RSpec.describe Beta::Search::SearchQueryParserResult::Standard do
  describe '.build' do
    subject(:result) { described_class.build(attributes) }

    let(:attributes) do
      {
        'tokens' => {
          'adjectives' => %w[tall],
          'nouns' => %w[man],
          'noun_chunks' => ['tall man'],
          'verbs' => [],
          'quoted' => ["'something quoted'"],
        },
        'original_search_query' => 'tall man',
        'corrected_search_query' => 'tall man',
      }
    end

    it { is_expected.to be_a(Beta::Search::SearchQueryParserResult) }
    it { expect(result.quoted).to eq(["'something quoted'"]) }
    it { expect(result.adjectives).to eq(%w[tall]) }
    it { expect(result.nouns).to eq(%w[man]) }
    it { expect(result.noun_chunks).to eq(['tall man']) }
    it { expect(result.verbs).to eq([]) }
    it { expect(result.original_search_query).to eq('tall man') }
    it { expect(result.corrected_search_query).to eq('tall man') }
    it { expect(result.id).to eq('cfbcdf9373a4864313877a2cedb58a3a') }
  end
end

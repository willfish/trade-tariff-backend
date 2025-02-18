RSpec.describe Api::V2::RulesOfOrigin::FullSchemeSerializer do
  subject { serializer.serializable_hash }

  let(:scheme_set) { build :rules_of_origin_scheme_set, links: [], schemes: [] }

  let :scheme do
    build :rules_of_origin_scheme,
          :with_links,
          :with_proofs,
          :with_origin_reference_document,
          scheme_set:,
          unilateral: true,
          show_proofs_for_geographical_areas: %w[AU]
  end

  let :rules do
    build_list :rules_of_origin_rule, 3, scheme_code: scheme.scheme_code
  end

  let :serializer do
    described_class.new \
      Api::V2::RulesOfOrigin::SchemePresenter.new(scheme, rules, []),
      include: %i[links proofs rules articles rule_sets rule_sets.rules origin_reference_document]
  end

  let :expected do
    {
      data: {
        id: scheme.scheme_code,
        type: :rules_of_origin_scheme,
        attributes: {
          scheme_code: scheme.scheme_code,
          title: scheme.title,
          countries: scheme.countries,
          cumulation_methods: scheme.cumulation_methods,
          footnote: scheme.footnote,
          unilateral: true,
          fta_intro: scheme.fta_intro,
          introductory_notes: scheme.introductory_notes,
          proof_intro: nil,
          proof_codes: {},
          show_proofs_for_geographical_areas: %w[AU],
        },
        relationships: {
          links: {
            data: [
              {
                id: scheme.links[0].id,
                type: :rules_of_origin_link,
              },
              {
                id: scheme.links[1].id,
                type: :rules_of_origin_link,
              },
            ],
          },
          origin_reference_document: {
            data: {
              id: scheme.origin_reference_document.id,
              type: :rules_of_origin_origin_reference_document,
            },
          },
          proofs: {
            data: [
              {
                id: scheme.proofs[0].id,
                type: :rules_of_origin_proof,
              },
              {
                id: scheme.proofs[1].id,
                type: :rules_of_origin_proof,
              },
            ],
          },
          rules: {
            data: [
              {
                id: rules[0].id_rule.to_s,
                type: :rules_of_origin_rule,
              },
              {
                id: rules[1].id_rule.to_s,
                type: :rules_of_origin_rule,
              },
              {
                id: rules[2].id_rule.to_s,
                type: :rules_of_origin_rule,
              },
            ],
          },
          articles: {
            data: [],
          },
          rule_sets: {
            data: [],
          },
        },
      },
      included: [
        {
          id: scheme.links[0].id,
          type: :rules_of_origin_link,
          attributes: {
            text: scheme.links[0].text,
            url: scheme.links[0].url,
            source: scheme.links[0].source,
          },
        },
        {
          id: scheme.links[1].id,
          type: :rules_of_origin_link,
          attributes: {
            text: scheme.links[1].text,
            url: scheme.links[1].url,
            source: scheme.links[1].source,
          },
        },
        {
          id: scheme.proofs[0].id,
          type: :rules_of_origin_proof,
          attributes: {
            summary: scheme.proofs[0].summary,
            url: scheme.proofs[0].url,
            subtext: scheme.proofs[0].subtext,
            content: scheme.proofs[0].content,
          },
        },
        {
          id: scheme.proofs[1].id,
          type: :rules_of_origin_proof,
          attributes: {
            summary: scheme.proofs[1].summary,
            url: scheme.proofs[1].url,
            subtext: scheme.proofs[1].subtext,
            content: scheme.proofs[1].content,
          },
        },
        {
          id: rules[0].id_rule.to_s,
          type: :rules_of_origin_rule,
          attributes: {
            id_rule: rules[0].id_rule,
            heading: rules[0].heading,
            description: rules[0].description,
            rule: rules[0].rule,
            alternate_rule: nil,
          },
        },
        {
          id: rules[1].id_rule.to_s,
          type: :rules_of_origin_rule,
          attributes: {
            id_rule: rules[1].id_rule,
            heading: rules[1].heading,
            description: rules[1].description,
            rule: rules[1].rule,
            alternate_rule: nil,
          },
        },
        {
          id: rules[2].id_rule.to_s,
          type: :rules_of_origin_rule,
          attributes: {
            id_rule: rules[2].id_rule,
            heading: rules[2].heading,
            description: rules[2].description,
            rule: rules[2].rule,
            alternate_rule: nil,
          },
        },
        {
          id: scheme.origin_reference_document.id,
          type: :rules_of_origin_origin_reference_document,
          attributes: {
            ord_date: scheme.origin_reference_document.ord_date,
            ord_original: scheme.origin_reference_document.ord_original,
            ord_title: scheme.origin_reference_document.ord_title,
            ord_version: scheme.origin_reference_document.ord_version,
          },
        },
      ],
    }
  end

  describe '#serializable_hash' do
    it { is_expected.to eql expected }
  end
end

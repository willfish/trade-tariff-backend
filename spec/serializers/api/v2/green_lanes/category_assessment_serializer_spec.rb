RSpec.describe Api::V2::GreenLanes::CategoryAssessmentSerializer do
  subject(:serialized) do
    described_class.new(
      presented,
      include: %w[exemptions geographical_area excluded_geographical_areas],
    ).serializable_hash.as_json
  end

  let(:category_assessment) { create :category_assessment, measure: }
  let(:certificate) { create :certificate, :exemption, :with_certificate_type, :with_description }
  let(:measure) { create :measure, :with_additional_code, :with_base_regulation, certificate: }

  let :presented do
    Api::V2::GreenLanes::CategoryAssessmentPresenter.wrap(category_assessment).first
  end

  let(:expected_pattern) do
    {
      data: {
        id: be_a(String),
        type: 'category_assessment',
        attributes: {
          category: category_assessment.theme.category.to_s,
          theme: category_assessment.theme.to_s,
        },
        relationships: {
          exemptions: {
            data: [
              { id: certificate.id, type: 'certificate' },
              { id: measure.additional_code.id.to_s, type: 'additional_code' },
            ],
          },
          geographical_area: {
            data: {
              id: measure.geographical_area_id,
              type: 'geographical_area',
            },
          },
          excluded_geographical_areas: {
            data: [],
          },
        },
      },
      included: [
        {
          id: certificate.id,
          type: 'certificate',
          attributes: {
            certificate_type_code: certificate.certificate_type_code,
            certificate_code: certificate.certificate_code,
            description: be_a(String),
            formatted_description: be_a(String),
          },
        },
        {
          id: '1',
          type: 'additional_code',
          attributes: {
            code: measure.additional_code.code,
            description: be_a(String),
            formatted_description: be_a(String),
          },
        },
        {
          id: measure.geographical_area_id,
          type: 'geographical_area',
          attributes: {
            id: measure.geographical_area_id,
            description: /\w+/,
            geographical_area_id: measure.geographical_area_id,
            geographical_area_sid: measure.geographical_area_sid,
          },
        },
      ],
    }
  end

  it { is_expected.to include_json(expected_pattern) }
end

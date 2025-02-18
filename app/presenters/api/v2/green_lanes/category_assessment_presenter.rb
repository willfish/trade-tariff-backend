# There is a One to Many mapping between Category Assessments and their Presented
# versions
#
# This is because we include exemptions and geographical areas in the serialized
# category assessments but they can vary depending upon the measures
#
# This means the presented versions get hashed ids including the various params
# used for their differentation (the 'permutation key')
module Api
  module V2
    module GreenLanes
      class CategoryAssessmentPresenter < SimpleDelegator
        include ContentAddressableId
        attr_reader :measures, :permutation_key

        delegate :geographical_area_id,
                 :geographical_area,
                 :excluded_geographical_areas,
                 :measure_conditions,
                 :additional_code,
                 to: :first_measure

        content_addressable_fields do |ca|
          ca.permutation_key.map(&:to_s).join("\n")
        end

        class << self
          def wrap(category_assessments)
            Array.wrap(category_assessments).flat_map do |assessment|
              permutations(assessment).map do |key, measures|
                new assessment, key, measures
              end
            end
          end

          private

          def permutations(assessment)
            ::GreenLanes::PermutationCalculatorService
              .new(assessment.measures)
              .call
          end
        end

        def initialize(category_assessment, permutation_key, measures)
          super(category_assessment)
          @category_assessment = category_assessment
          @permutation_key = permutation_key
          @measures = MeasurePresenter.wrap(measures)
        end

        def measure_ids
          @measure_ids = measures.map(&:measure_sid)
        end

        def theme
          @category_assessment.theme.to_s
        end

        def category
          @category_assessment.theme.category.to_s
        end

        def category_assessment_id
          @category_assessment.id
        end

        def excluded_geographical_area_ids
          excluded_geographical_areas.map(&:geographical_area_id)
        end

        def exemptions
          certificates + additional_codes
        end

        def certificates
          measure_conditions.select(&:exemption_class?).map(&:certificate)
        end

        def additional_codes
          Array.wrap(additional_code)
        end

      private

        def first_measure
          measures.first
        end
      end
    end
  end
end

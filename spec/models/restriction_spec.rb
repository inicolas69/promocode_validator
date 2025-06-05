require "rails_helper"

RSpec.describe Restriction, type: :model do
  before do
    allow_any_instance_of(Restriction).to receive(:validate_conditions) # stub the method to avoid validation errors which are tested in subclasses
  end

  describe "associations" do
    it { is_expected.to belong_to(:restriction_group) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:conditions) }
  end

  describe "database columns" do
    it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:conditions).of_type(:jsonb).with_options(null: false, default: {}) }
  end
end

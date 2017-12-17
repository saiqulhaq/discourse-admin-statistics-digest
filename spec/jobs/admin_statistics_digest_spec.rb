# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/jobs/admin_statistics_digest'

RSpec.describe Jobs::AdminStatisticsDigest do
  describe '#sending_email?' do
    context 'SiteSetting.disable_emails == false' do
      before { SiteSetting.disable_emails = false }

      it 'returns true' do
        expect(subject.sending_email?).to be_truthy
      end
    end

    context 'SiteSetting.disable_emails == true' do
      before { SiteSetting.disable_emails = true }

      it 'returns true' do
        expect(subject.sending_email?).to be_falsey
      end
    end
  end
end

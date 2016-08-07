require_relative '../spec_helper'

describe AdminStatisticsDigest::Report do
  let(:reporter) { described_class.new }

  describe '#active_users' do
    describe 'arguments' do

      it 'accepts :signed_up_from parameter optionally' do
        expect {
          reporter.active_users signed_up_from: 1.month.ago
        }.not_to raise_error
      end

      it 'accepts :signed_up_between parameter optionally' do
        expect {
          reporter.active_users signed_up_between: 3.month.ago...1.month.ago
        }.not_to raise_error
      end

      it 'accepts :include_staff parameter optionally' do
        expect {
          reporter.active_users include_staff: true
        }.not_to raise_error
      end

      it 'accepts :specs argument to specify active specification' do
        expect { reporter.active_users specs: [] }.not_to raise_error
      end

    end

    describe 'when no users' do
      subject { reporter.active_users }
      it { is_expected.to include({ error: nil }) }
      it { is_expected.to include({ data: [] }) }
      it { is_expected.to have_key(:duration) }
    end

    describe 'given there are 10 users and the active specs = [topics, replies]' do

      before do
        @users = Fabricate.times(10, :user)
        q = AdminStatisticsDigest::Specs::ActiveUser.new
        q.specs.add 'topics'
        q.specs.add 'replies'
      end

      describe '3 of users have some posts and topics' do

        before do
          @users.take(3).each do |user|
            Fabricate.times([1,2].sample, :topic, user: user).each do |topic|
              Fabricate.times([1,2].sample, :post, topic: topic, user: user)
            end
          end
        end

        it 'returns those 3 users in top result' do
          expect(reporter.active_users[:data].entries.take(3).map {|e| e["user_id"].to_i }.sort).to(
            eq(@users.take(3).map(&:id).sort))
        end
      end

    end
  end

end

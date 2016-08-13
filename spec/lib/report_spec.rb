require_relative '../spec_helper'

describe AdminStatisticsDigest::Report do
  let(:reporter) { described_class.new }
  let(:const) { AdminStatisticsDigest::Specs::ActiveUser }
  let(:specs) { AdminStatisticsDigest::Specs::ActiveUser.new }

  describe '#active_users' do

    describe 'arguments' do
      context 'no specs defined' do
        before { specs.reset }
        before { Fabricate.times(3, :user) }

        describe ':signed_up_from argument' do
          it 'returns empty data' do
            expect(reporter.active_users(signed_up_from: 8.days.ago)[:data].count).to eq(0)
          end
        end

        describe ':signed_up_between argument' do
          it 'returns empty data' do
            expect(reporter.active_users(signed_up_between: 22.days.ago...3.days.ago)[:data].count).to eq(0)
          end
        end

        describe ':include_staff argument' do
          it 'returns empty data' do
            expect(reporter.active_users(include_staff: true)[:data].count).to eq(0)
          end
        end
      end

      context 'specs is defined' do
        before { specs.add(const::TOPICS) }

        describe ':signed_up_from argument' do
          it 'returns users filtered by created_at >= :signed_up_from argument' do
            Timecop.freeze(30.days.ago) do
              Fabricate.times(3, :user)
            end
            Timecop.freeze(7.days.ago) do
              @users = Fabricate.times(5, :user)
            end

            report = reporter.active_users(signed_up_from: 8.days.ago)
            expect(report[:error]).to be_nil
            expect(report[:data].count).to eq(5)
          end
        end

        describe ':signed_up_between argument' do
          it 'returns users filtered_by created_at between given parameter data' do
            Timecop.freeze(30.days.ago) do
              Fabricate.times(2, :user)
            end

            Timecop.freeze(20.days.ago) do
              Fabricate.times(2, :user)
            end

            Timecop.freeze(10.days.ago) do
              Fabricate.times(2, :user)
            end

            report = reporter.active_users(signed_up_between: 22.days.ago...3.days.ago)
            expect(report[:error]).to be_nil
            expect(report[:data].count).to eq(4)
          end
        end

        describe ':include_staff argument' do
          it 'returns admin and moderator users if value is equal true' do
            Fabricate.times(2, :moderator)
            Fabricate.times(2, :admin)
            Fabricate.times(2, :user)

            report = reporter.active_users
            expect(report[:error]).to be_nil
            expect(report[:data].count).to eq(2)

            report = reporter.active_users(include_staff: true)
            expect(report[:error]).to be_nil
            expect(report[:data].count).to eq(6)
          end
        end

      end
    end

    context  'no users data' do
      subject { reporter.active_users }
      it { is_expected.to include({ error: nil }) }
      it { is_expected.to include({ data: [] }) }
      it { is_expected.to have_key(:duration) }
    end

    describe 'reporting' do

      context 'given there are 10 users ' do
        before do
          @users = Fabricate.times(10, :user)
          specs.reset
        end

        context 'when specs = "topics, and replies"' do
          before do
            specs.add const::TOPICS
            specs.add const::REPLIES
          end
          before do
            @users.take(3).each do |user|
              Fabricate.times([1,2].sample, :topic, user: user).each do |topic|
                Fabricate.times([1,2].sample, :post, topic: topic, user: user)
              end
            end
          end

          it 'returns users sorted by replies and topics' do
            expect(reporter.active_users[:data].entries.take(3).map {|e| e['user_id'].to_i }.sort).
              to(eq(@users.take(3).map(&:id).sort))
          end
        end

        context 'when specs = "like received"' do
          before { specs.add const::LIKE_RECEIVED }

          before do
            another_users = @users.take(3)
            @users.take(3).each do |user|
              post = Fabricate(:post, user: user)
              another_users.each do |an_user|
                UserAction.create!(action_type: UserAction::WAS_LIKED, user_id: user.id, target_topic_id: post.topic.id, target_post_id: post.id, acting_user_id: an_user.id)
              end
            end
          end

          it 'returns users sorted by like received' do
            result = reporter.active_users[:data]
            expect(result.first['like_received']).to_not eq(0)
            expect(result.entries.take(3).map {|e| e['user_id'].to_i }.sort).to(
              eq(@users.take(3).map(&:id).sort))
          end
        end

        context 'when specs = "like given"' do
          before { specs.add(const::LIKE_GIVEN) }
          before do
            another_users = @users.take(3)
            @users.take(3).each do |user|
              post = Fabricate(:post, user: user)
              another_users.each do |an_user|
                UserAction.create!(action_type: UserAction::LIKE, user_id: user.id, target_topic_id: post.topic.id, target_post_id: post.id, acting_user_id: an_user.id)
              end
            end
          end

          it 'returns users sorted by like received' do
            result = reporter.active_users[:data]
            expect(result.first['like_given']).to_not eq(0)
            expect(result.entries.take(3).map {|e| e['user_id'].to_i }.sort).to(
              eq(@users.take(3).map(&:id).sort))
          end
        end

        context 'when specs = "read"' do
          before { specs.add(const::READ) }
          before do
            @users.each {|u| u.update_last_seen!}
            read = 10
            @users.reverse.take(3).each do |user|
              user.update_posts_read!(read)
              read -= 1
            end
          end

          it 'returns users sorted by posts read' do
            result = reporter.active_users[:data]
            expect(result.first['read'].to_i).to eq(10)
            expect(result.entries.take(3).map {|e| e['user_id'].to_i }.sort).to(
              eq(@users.reverse.take(3).map(&:id).sort))
          end
        end

        context 'when specs = "visits"' do
          before { specs.add(const::VISITS) }
          before do
            @sorted_users = @users.map do |user|
              visits = rand(20)
              visits.times do |i|
                UserVisit.create! user_id: user.id, visited_at: i.day.ago
              end
              { id: user.id, days_visited: visits }
            end.sort { |x,y| x[:days_visited] <=> y[:days_visited] }

          end

          it 'returns users sorted by posts read' do
            result = reporter.active_users[:data]
            expect(result.map{ |u| u[:user_id] }).to eq(@sorted_users.map { |u| u['days_visited'] })
          end

        end
      end

    end
  end
end


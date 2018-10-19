module TSX
  module Games

      module Voting

        def game_allowed?
          hb_client.has_vote?
        end

        def progress
          "#{self.conf('counter')} раз проголосовано."
        end

        def winner
          Vote::best_this_month
        end

      end

      module Lottery

        def available_numbers
          nums = []
          rng = eval("#{conf('range')}")
          Bet.where(game: self[:id]).each do |num|
            nums.push(num.number)
          end
          rng - nums
        end

        def game_allowed?(bot, client)
          b = Gameplay[self.id]
          v = !Bet.find(client: client.id, game: b.id).nil?
          puts "Result: #{v}".colorize(:white_on_red)
          !v
        end

        def progress
          counter = Bet.where(game: self.id).count
          puts "#{self.conf('range').inspect}"
          maxi = eval("#{self.conf('range')}").count
          "#{counter} из #{maxi}"
        end

        def winner
          if !self.winner.nil?
            wnner = Client[self.winner]
            "#{icn('id')} <b>#{wnner.id}</b> @#{wnner.username}"
          end
        end

      end

      module Announcement

        def progress
          "#{self.conf('counter')} просмотров."
        end

        def winner
          ""
        end

      end

      module Referals

        def progress
          "#{self.conf('counter')} просмотров."
        end

        def winner
          "нет данных"
        end

      end

  end
end